package io.kamihama.magianative;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.security.cert.CertificateException;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class RestClient {
    private final String Endpoint = "https://walpurgisnacht.rayshift.io";
    private final String LogTag = "MagiaClientJNI";
    private String UserAgent = "okhttp3 " + System.getProperty("http.agent");

    public String GetEndpoint(int version) {
        JSONObject jsonString = new JSONObject();

        try {
            jsonString.put("version", version);
        } catch (JSONException e) {
            Log.e(LogTag, "Error adding version: " + e.toString());
            return "";
        }

        try {
            return postRequest(Endpoint + "/api/v1/endpoint", jsonString.toString());
        } catch (IOException e) {
            Log.e(LogTag, "Error with request: " + e.toString());
            return "";
        }
    }

    private static final MediaType JSON
            = MediaType.parse("application/json; charset=utf-8");

    private OkHttpClient client = getUnsafeOkHttpClient();

    private String postRequest (String url, String json) throws IOException {
        RequestBody body = RequestBody.create(JSON, json); // new
        // RequestBody body = RequestBody.create(JSON, json); // old
        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .removeHeader("User-Agent")
                .addHeader("User-Agent", UserAgent)
                .build();

        Response response = client.newCall(request).execute();

        // Temporary workaround
        if ((response.code() == 307) || (response.code() == 308)) {
            String location = response.header("Location");
            if (location != null) {
                request = request.newBuilder()
                        .url(location)
                        .post(body)
                        .removeHeader("User-Agent")
                        .addHeader("User-Agent", UserAgent)
                        .build();

                Response newResponse = client.newCall(request).execute();
                return newResponse.body() != null ? newResponse.body().string() : "";
            }
        }
        return response.body() != null ? response.body().string() : "";
    }

    public static OkHttpClient getUnsafeOkHttpClient() {
        try {
            // Create a trust manager that does not validate certificate chains
            final TrustManager[] trustAllCerts = new TrustManager[] {
                    new X509TrustManager() {
                        @Override
                        public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                            return new java.security.cert.X509Certificate[]{};
                        }
                    }
            };

            // Install the all-trusting trust manager
            final SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
            // Create an ssl socket factory with our all-trusting manager
            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            OkHttpClient.Builder builder = new OkHttpClient.Builder();
            builder.sslSocketFactory(sslSocketFactory, (X509TrustManager)trustAllCerts[0]);
            builder.hostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            });

            OkHttpClient okHttpClient = builder.build();
            return okHttpClient;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
