import java.io.IOException;

import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.runtime.client.EPRuntime;
import com.espertech.esper.runtime.client.EPRuntimeProvider;
import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

public class Main {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

//      --24
//        "select istream spolka as X, kursOtwarcia as Y " +
//                "from KursAkcji.win:length(3) "+
//                "WHERE spolka='Oracle'"
//      --25
//        "select istream data, spolka , kursOtwarcia " +
//                "from KursAkcji.win:length(3) "+
//                "WHERE spolka='Oracle'"
//      --26
//        "select istream data, spolka , kursOtwarcia " +
//                "from KursAkcji(spolka='Oracle').win:length(3) "+
//                "WHERE spolka='Oracle'"
//      --27
//        "select istream data, spolka , kursOtwarcia " +
//                "from KursAkcji(spolka='Oracle').win:length(3) "+
//                "WHERE spolka='Oracle'"
//      --28
//        "select istream data, spolka , max(kursOtwarcia) " +
//                "from KursAkcji(spolka='Oracle').win:length(5) "+
//                "group by spolka"
//      --29
//        "select istream data, spolka , kursOtwarcia - max(kursOtwarcia) as roznica " +
//                "from KursAkcji(spolka='Oracle').win:length(5) "+
//                "group by spolka"
//      --30
//        "select istream data, spolka ,  max(kursOtwarcia) - min(kursOtwarcia) as roznica " +
//                "from KursAkcji(spolka='Oracle').win:length(2) "+
//                "group by spolka " +
//                "having (kursOtwarcia - min(kursOtwarcia)) >0"


        EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka ,  max(kursOtwarcia) - min(kursOtwarcia) as roznica " +
                        "from KursAkcji(spolka='Oracle').win:length(2) "+
                        "group by spolka " +
                        "having (kursOtwarcia - min(kursOtwarcia)) >0"
        );
        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }
}

