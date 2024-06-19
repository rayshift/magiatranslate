package io.kamihama.magianative;

import android.content.Context;
import android.os.Build;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;

import androidx.annotation.RequiresApi;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import okhttp3.Headers;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

// https://stackoverflow.com/questions/17272612/android-webview-disable-cors
public class OptionsAllowResponse {
    static final String proxyHost = "magirecojp.cirno.name";
    static final String host = "android.magi-reco.com";
    static final String topPageJsPath = "/magica/js/top/TopPage.js";

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private static Request buildRequest(WebResourceRequest request, String mediaType) {
        // wipe out traces of cross-site request
        Request.Builder builder = new Request.Builder()
                .url(request.getUrl().toString());

        if (request.getMethod().equalsIgnoreCase("POST")) {
            builder = builder.post(RequestBody.create(MediaType.parse(mediaType), "null"));
        } else {
            builder = builder.get();
        }

        builder = builder.removeHeader("Accept-Encoding")
                .addHeader("Accept-Encoding", "gzip, deflate")
                .removeHeader("Accept-Language")
                .addHeader("Accept-Language", "ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7")
                .addHeader("Sec-Fetch-Site", "same-origin")
                .addHeader("Sec-Fetch-Mode", "cors")
                .addHeader("Sec-Fetch-Dest", "empty");

        for (Map.Entry<String, String> entry : request.getRequestHeaders().entrySet()) {
            String key = entry.getKey();
            String val = entry.getValue().replace(proxyHost, host);
            builder.removeHeader(key).addHeader(key, val);
        }

        return builder.build();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
        String path = request.getUrl().getPath();
        String method = request.getMethod();

        OkHttpClient client = RestClient.getUnsafeOkHttpClient();

        final String allowedHeaders = "client-model-name,client-os-ver,client-session-id,content-type,f4s-client-ver,user-id-fba9x88mae,webview-session-id,x-platform-host,x-requested-with";
        Map<String, String> respHeaders = new HashMap<String, String>() {{
            put("Connection", "close");
            put("Content-Type", "text/plain");
            put("Date", new SimpleDateFormat("E, dd MMM yyyy kk:mm:ss", Locale.US).format(new Date()) + " GMT");
            put("Access-Control-Allow-Origin", "https://" + proxyHost);
            put("Access-Control-Allow-Methods", "GET, POST, DELETE, PUT, OPTIONS");
            put("Access-Control-Max-Age", "600");
            put("Access-Control-Allow-Credentials", "true");
            put("Access-Control-Allow-Headers", allowedHeaders);
            put("Via", "1.1 vegur");
        }};

        if (path.equals(topPageJsPath) || path.startsWith(topPageJsPath + "?")) {
            // JavaScript injection
            try {
                Response response = client.newCall(buildRequest(request, "application/javascript; charset=utf-8")).execute();
                if (response.code() == 200) {
                    String respStr = response.body().string();

                    final String prefix1 = "transferPop:function(){";
                    final String inserted1 = "(typeof g==='object'&&typeof g.getPageJson==='function'&&typeof b==='object'&&typeof b.userDataInitilize==='function'&&typeof b.closeGame==='function'&&(window.confirm(\"Current country code: [\"+(function(){try{return g.getPageJson().user.country;}catch(e){}})()+\"], Log out to reset country code AND id?\")?(b.userDataInitilize(),window.alert(\"Please restart game manually\"),b.closeGame()):(window.prompt(\"You may copy the id below for external transfer\",window.g_sns)))),this.origTransferPop()},origTransferPop:function(){";
                    final String suffix1 = "if(";

                    final String prefix2 = ";l.has(e.user,\"id\")||";
                    final String inserted2 = "(function(){try{" +
                            "if(typeof fetch==='function'&&typeof a==='object'&&typeof a.tapBlock==='function'&&typeof a.loading==='object'&&typeof a.loading.show==='function'&&typeof a.loading.hide==='function'){" +
                            "a.tapBlock(true);a.loading.show();" +
                            "let isSuccessful = false;" +
                            "let h = new Headers();" +
                            "const o = \"https://android.magi-reco.com\";" +
                            "h.append(\"Client-Os-Ver\",window.osVersion);" +
                            "h.append(\"X-Platform-Host\",o.replace(\"https://\",\"\"));" +
                            "h.append(\"User-Id-Fba9x88mae\",window.g_sns);" +
                            "h.append(\"Client-Model-Name\",window.modelName);" +
                            "h.append(\"Content-Type\",\"application/JSON\");" +
                            "h.append(\"Accept\",\"application/json, text/javascript, */*; q=0.01\");" +
                            "h.append(\"Webview-Session-Id\",window.webInitTime);" +
                            "h.append(\"X-Requested-With\",\"XMLHttpRequest\");" +
                            "h.append(\"Client-Session-Id\",window.bootCount);" +
                            "h.append(\"F4s-Client-Ver\",window.app_ver);" +
                            "h.append(\"Origin\",o);" +
                            "h.append(\"Sec-Fetch-Site\",\"same-origin\");" +
                            "h.append(\"Sec-Fetch-Mode\",\"cors\");" +
                            "h.append(\"Sec-Fetch-Dest\",\"empty\");" +
                            "h.append(\"Referer\",h+\"/magica/index.html\");" +
                            "h.append(\"Accept-Encoding\",\"gzip, deflate\");" +
                            "fetch(o+'/magica/api/user/create',{" +
                            "method:\"post\"," +
                            "mode:\"cors\"," +
                            "credentials:\"include\"," +
                            "body:\"null\"," +
                            "headers:h" +
                            "}).then(r=>r.text()).then(r=>{r=JSON.parse(r);(isSuccessful=r!=null&&r.resultCode===\"success\"&&r.user!=null)&&window.alert(\"Successfully obtained country code [\"+r.user.country+\"], please manually restart the app\");b.closeGame()});" +
                            "setTimeout(function(){if(isSuccessful)return;window.prompt(\"Please manually restart the app, or try external transfer with the id below\",window.g_sns);b.closeGame()},10000);" +
                            "return true;}" +
                            "}catch(e){};return false})()||";
                    final String suffix2 = "g.ajaxPost(a.linkList.createUser,";

                    respStr = respStr.replace(prefix1 + suffix1, prefix1 + inserted1 + suffix1);
                    respStr = respStr.replace(prefix2 + suffix2, prefix2 + inserted2 + suffix2);

                    InputStream data = new ByteArrayInputStream(respStr.getBytes("UTF-8"));
                    respHeaders.put("Content-Type", "application/javascript; charset=UTF-8");
                    return new WebResourceResponse("application/javascript", "UTF-8", 200, "OK", respHeaders, data);
                }
            } catch (IOException e) {} // just let the webview retry
        } else if (path.equals("/magica/api/user/create")) {
            // allow CORS on preflight request
            if (method.equalsIgnoreCase("OPTIONS")) {
                return new WebResourceResponse("text/plain", "UTF-8", 200, "OK", respHeaders, null);
            }

            // fetch result on our own
            InputStream data = null;
            try {
                data = new ByteArrayInputStream("{\"resultCode\":\"error\"}".getBytes("UTF-8"));
                Response response = client.newCall(buildRequest(request, "application/json; charset=utf-8")).execute();
                if (response.code() == 200) {
                    respHeaders.put("Content-Type", "application/json;charset=UTF-8");
                    return new WebResourceResponse("application/json", "UTF-8", 200, "OK", respHeaders, response.body().byteStream());
                }
            } catch (IOException e) {
                // handled by injected javascript, isSuccessful won't be true
                return new WebResourceResponse("application/json", "UTF-8", 408, "Request Timeout", respHeaders, data);
            }
        }

        return null;
    }
}