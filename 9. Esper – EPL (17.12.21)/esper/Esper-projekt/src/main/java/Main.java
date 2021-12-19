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
//Ctrl+Alt+Shift+L
//
//       --5
//        "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica "+
//                "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 days) "
//        --6
//        "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica "+
//                "from KursAkcji(spolka='Honda' or spolka='IBM' or spolka='Microsoft').win:ext_timed_batch(data.getTime(), 1 days) "
//        --7
//        statyczna metoda
//        "select istream data, spolka, kursZamkniecia, kursOtwarcia "+
//                "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 days) "
//                + " where KursAkcji.czyBylWzrostTegoDnia(kursOtwarcia, kursZamkniecia) is True"
//        wyrazenie
//        "select istream data, spolka, kursZamkniecia, kursOtwarcia "+
//                "from KursAkcji(kursZamkniecia-kursOtwarcia>0).win:ext_timed_batch(data.getTime(), 1 days) "
//        --8
//        "select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica "+
//                "from KursAkcji(spolka = 'PepsiCo' or spolka = 'CocaCola').win:ext_timed(data.getTime(), 7 days) "
//      --9
//        "select istream data, spolka, max(kursZamkniecia) "+
//                "from KursAkcji(spolka = 'PepsiCo' or spolka = 'CocaCola').win:ext_timed_batch(data.getTime(), 1 days) "
//                +" group by data "
//                + " limit 1 "
//      --10
//        "select istream  max(kursZamkniecia) as maksimum "+
//                "from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days) "
//                +" group by data " + " order by max(kursZamkniecia) desc"+
//                " limit 1"
//      --11
//        " select pc.kursZamkniecia, cc.kursZamkniecia, pc.data "+
//                " from KursAkcji(spolka='PepsiCo').win:ext_timed(data.getTime(), 1 days)  as pc " +
//                " full outer join KursAkcji(spolka='CocaCola').win:ext_timed(data.getTime(), 1 days) as cc " +
//                " ON cc.data= pc.data "
//                +" where pc.kursZamkniecia > cc.kursZamkniecia "
//        --12
//        "select istream k.data, k.spolka, tmp.kursZamkniecia, k.kursZamkniecia -tmp.kursZamkniecia as roznica "
//                +" from KursAkcji(spolka='PepsiCo' or spolka='CocaCola').win:firsttime(1 year) k "
//                +" full outer join KursAkcji(spolka='PepsiCo' or spolka='CocaCola').win:ext_timed(data.getTime(), 1 days) as tmp "
//                +" on k.spolka = tmp.spolka"
//                +" where k.data.getDayOfMonth() = 5 and k.data.getYear() = 2001"
//        --13
//        "select istream k.data, tmp.data, k.spolka, tmp.kursZamkniecia, tmp.kursZamkniecia-k.kursZamkniecia as roznica "
//                +" from KursAkcji(data.getDayOfMonth() = 5, data.getYear() = 2001).win:firsttime(100 year) k "
//                +" full outer join KursAkcji().win:ext_timed(data.getTime(), 1 days) as tmp "
//                +" on k.spolka = tmp.spolka"
//                + " where k.kursZamkniecia <tmp.kursZamkniecia "
//        --14
//        "select istream k.data, tmp.data, k.spolka, tmp.kursOtwarcia, k.kursOtwarcia "
//                +" from KursAkcji().win:ext_timed(data.getTime(), 3 days) k "
//                +" full outer join KursAkcji().win:ext_timed(data.getTime(), 3 days) as tmp "
//                +" on k.spolka = tmp.spolka"
//                + " where tmp.kursOtwarcia - k.kursOtwarcia >3 or tmp.kursOtwarcia - k.kursOtwarcia<-3"
//      --15
//        "select istream data, spolka, obrot "
//                +" from KursAkcji(market= 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) "
//                + " order by obrot desc"
//                + " limit 3"
//        --16
//        "select istream data, spolka, obrot "
//                +" from KursAkcji(market= 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) "
//                + " order by obrot desc"
//                + " limit 1 offset 2"

        EPDeployment deployment = compileAndDeploy(epRuntime,
        "select istream data, spolka, obrot "
                +" from KursAkcji(market= 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) "
                + " order by obrot desc"
                + " limit 1 offset 2"


                //-------------------

                //-------------------





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

