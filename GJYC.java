package autopack;

/**
 * 刘秀君项目部打包
 */

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by anyware on 17/3/30.
 */
public class GJYC {
    private static String BASE = "/Users/anyware/Documents/CompanyProject/OtherProgramer/gjyc/";
    private static String SHELL_FILE_DIR = BASE + "hyzmgjj";//工程目录

    private static String srcDir = BASE + "www";//要打包的www代码地址
    private static String cer_path = BASE + "cert/dis/cert.p12";//证书路径
    private static String mobileprovision_file = BASE + "cert/dis/hyzmgjjdistributionqiye.mobileprovision";//描述文件地址

    private static String keychain_pass = "123456";//钥匙串密码
    private static String BundleID = "com.chinasofti.hyzmgjj";  //
    private static String bundleVersion = "1.1.0"; //版本号appid
    private static String packageUrl = "172.16.1.217:22/ipa";//ipa包地址 只有发布到appstore的不需要plist文件
    private static String p12_pass = "123456";
    private static String packDate = getCurrentDate();

    private static String pluginPath = "";
    private static String appIconPath = "";
    private static String lanchImagePath = BASE + "images/splash/splash.png";
//    private static String lanchImagePath = "";

    private static String templateName = "hyzmgjj";
    private static String schemeName = "hyzmgjj";
    private static String ownerName = "anyware";


    private static String getCurrentDate() {
        Date date = new Date();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        return format.format(date);
    }

    public static void main(String args[]) {
        startBuild("hyzmgjj", "国家专卖");
    }

    public static void startBuild(String projectName, String displayName) {
        String keychain_name = projectName + ".keychain";
        ProcessBuilder pb = new ProcessBuilder("./start.sh",
                srcDir, cer_path, mobileprovision_file, keychain_pass, keychain_name, p12_pass, BundleID, projectName,
                bundleVersion, packageUrl, displayName, packDate,
                pluginPath, appIconPath, lanchImagePath,
                templateName, schemeName, ownerName);
        pb.directory(new File(SHELL_FILE_DIR));
        int runningStatus = 0;
        String s = null;
        try {
            Process p = pb.start();
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
            while ((s = stdInput.readLine()) != null) {
                System.out.println(s);
            }
            while ((s = stdError.readLine()) != null) {
                System.out.println(s);
            }

            try {
                System.out.println("start...");
                runningStatus = p.waitFor();
                System.out.println("finish");
            } catch (InterruptedException e) {
                System.out.println("出错了");
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
        if (runningStatus == 0) {
            System.out.println("success");
        } else {
            System.out.println("Error");
        }
    }
}
