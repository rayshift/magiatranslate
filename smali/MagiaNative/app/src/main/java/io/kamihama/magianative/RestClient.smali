.class public Lio/kamihama/magianative/RestClient;
.super Ljava/lang/Object;
.source "RestClient.java"


# static fields
.field private static final JSON:Lokhttp3/MediaType;


# instance fields
.field private final Endpoint:Ljava/lang/String;

.field private final LogTag:Ljava/lang/String;

.field private UserAgent:Ljava/lang/String;

.field private client:Lokhttp3/OkHttpClient;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const-string v0, "application/json; charset=utf-8"

    .line 48
    invoke-static {v0}, Lokhttp3/MediaType;->parse(Ljava/lang/String;)Lokhttp3/MediaType;

    move-result-object v0

    sput-object v0, Lio/kamihama/magianative/RestClient;->JSON:Lokhttp3/MediaType;

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .line 24
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const-string v0, "https://walpurgisnacht.rayshift.io"

    .line 25
    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->Endpoint:Ljava/lang/String;

    const-string v0, "MagiaClientJNI"

    .line 26
    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->LogTag:Ljava/lang/String;

    .line 27
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "okhttp3 "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    const-string v1, "http.agent"

    invoke-static {v1}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->UserAgent:Ljava/lang/String;

    .line 50
    invoke-static {}, Lio/kamihama/magianative/RestClient;->getUnsafeOkHttpClient()Lokhttp3/OkHttpClient;

    move-result-object v0

    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->client:Lokhttp3/OkHttpClient;

    return-void
.end method

.method public static getUnsafeOkHttpClient()Lokhttp3/OkHttpClient;
    .locals 5

    const/4 v0, 0x1

    :try_start_0
    new-array v0, v0, [Ljavax/net/ssl/TrustManager;

    .line 85
    new-instance v1, Lio/kamihama/magianative/RestClient$1;

    invoke-direct {v1}, Lio/kamihama/magianative/RestClient$1;-><init>()V

    const/4 v2, 0x0

    aput-object v1, v0, v2

    const-string v1, "SSL"

    .line 103
    invoke-static {v1}, Ljavax/net/ssl/SSLContext;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/SSLContext;

    move-result-object v1

    .line 104
    new-instance v3, Ljava/security/SecureRandom;

    invoke-direct {v3}, Ljava/security/SecureRandom;-><init>()V

    const/4 v4, 0x0

    invoke-virtual {v1, v4, v0, v3}, Ljavax/net/ssl/SSLContext;->init([Ljavax/net/ssl/KeyManager;[Ljavax/net/ssl/TrustManager;Ljava/security/SecureRandom;)V

    .line 106
    invoke-virtual {v1}, Ljavax/net/ssl/SSLContext;->getSocketFactory()Ljavax/net/ssl/SSLSocketFactory;

    move-result-object v1

    .line 108
    new-instance v3, Lokhttp3/OkHttpClient$Builder;

    invoke-direct {v3}, Lokhttp3/OkHttpClient$Builder;-><init>()V

    aget-object v0, v0, v2

    .line 109
    check-cast v0, Ljavax/net/ssl/X509TrustManager;

    invoke-virtual {v3, v1, v0}, Lokhttp3/OkHttpClient$Builder;->sslSocketFactory(Ljavax/net/ssl/SSLSocketFactory;Ljavax/net/ssl/X509TrustManager;)Lokhttp3/OkHttpClient$Builder;

    .line 110
    new-instance v0, Lio/kamihama/magianative/RestClient$2;

    invoke-direct {v0}, Lio/kamihama/magianative/RestClient$2;-><init>()V

    invoke-virtual {v3, v0}, Lokhttp3/OkHttpClient$Builder;->hostnameVerifier(Ljavax/net/ssl/HostnameVerifier;)Lokhttp3/OkHttpClient$Builder;

    .line 117
    invoke-virtual {v3}, Lokhttp3/OkHttpClient$Builder;->build()Lokhttp3/OkHttpClient;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    :catch_0
    move-exception v0

    .line 120
    new-instance v1, Ljava/lang/RuntimeException;

    invoke-direct {v1, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw v1
.end method

.method private postRequest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 53
    sget-object v0, Lio/kamihama/magianative/RestClient;->JSON:Lokhttp3/MediaType;

    invoke-static {v0, p2}, Lokhttp3/RequestBody;->create(Lokhttp3/MediaType;Ljava/lang/String;)Lokhttp3/RequestBody;

    move-result-object p2

    .line 55
    new-instance v0, Lokhttp3/Request$Builder;

    invoke-direct {v0}, Lokhttp3/Request$Builder;-><init>()V

    .line 56
    invoke-virtual {v0, p1}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    .line 57
    invoke-virtual {p1, p2}, Lokhttp3/Request$Builder;->post(Lokhttp3/RequestBody;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v0, "User-Agent"

    .line 58
    invoke-virtual {p1, v0}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    iget-object v1, p0, Lio/kamihama/magianative/RestClient;->UserAgent:Ljava/lang/String;

    .line 59
    invoke-virtual {p1, v0, v1}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    .line 60
    invoke-virtual {p1}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;

    move-result-object p1

    .line 62
    iget-object v1, p0, Lio/kamihama/magianative/RestClient;->client:Lokhttp3/OkHttpClient;

    invoke-virtual {v1, p1}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object v1

    invoke-interface {v1}, Lokhttp3/Call;->execute()Lokhttp3/Response;

    move-result-object v1

    .line 65
    invoke-virtual {v1}, Lokhttp3/Response;->code()I

    move-result v2

    const/16 v3, 0x133

    const-string v4, ""

    if-eq v2, v3, :cond_0

    invoke-virtual {v1}, Lokhttp3/Response;->code()I

    move-result v2

    const/16 v3, 0x134

    if-ne v2, v3, :cond_2

    :cond_0
    const-string v2, "Location"

    .line 66
    invoke-virtual {v1, v2}, Lokhttp3/Response;->header(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    if-eqz v2, :cond_2

    .line 68
    invoke-virtual {p1}, Lokhttp3/Request;->newBuilder()Lokhttp3/Request$Builder;

    move-result-object p1

    .line 69
    invoke-virtual {p1, v2}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    .line 70
    invoke-virtual {p1, p2}, Lokhttp3/Request$Builder;->post(Lokhttp3/RequestBody;)Lokhttp3/Request$Builder;

    move-result-object p1

    .line 71
    invoke-virtual {p1, v0}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    iget-object p2, p0, Lio/kamihama/magianative/RestClient;->UserAgent:Ljava/lang/String;

    .line 72
    invoke-virtual {p1, v0, p2}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    .line 73
    invoke-virtual {p1}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;

    move-result-object p1

    .line 75
    iget-object p2, p0, Lio/kamihama/magianative/RestClient;->client:Lokhttp3/OkHttpClient;

    invoke-virtual {p2, p1}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object p1

    invoke-interface {p1}, Lokhttp3/Call;->execute()Lokhttp3/Response;

    move-result-object p1

    .line 76
    invoke-virtual {p1}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object p2

    if-eqz p2, :cond_1

    invoke-virtual {p1}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object p1

    invoke-virtual {p1}, Lokhttp3/ResponseBody;->string()Ljava/lang/String;

    move-result-object v4

    :cond_1
    return-object v4

    .line 79
    :cond_2
    invoke-virtual {v1}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object p1

    if-eqz p1, :cond_3

    invoke-virtual {v1}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object p1

    invoke-virtual {p1}, Lokhttp3/ResponseBody;->string()Ljava/lang/String;

    move-result-object v4

    :cond_3
    return-object v4
.end method


# virtual methods
.method public GetEndpoint(I)Ljava/lang/String;
    .locals 4

    const-string v0, ""

    const-string v1, "MagiaClientJNI"

    .line 30
    new-instance v2, Lorg/json/JSONObject;

    invoke-direct {v2}, Lorg/json/JSONObject;-><init>()V

    :try_start_0
    const-string v3, "version"

    .line 33
    invoke-virtual {v2, v3, p1}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    :try_end_0
    .catch Lorg/json/JSONException; {:try_start_0 .. :try_end_0} :catch_1

    :try_start_1
    const-string p1, "https://walpurgisnacht.rayshift.io/api/v1/endpoint"

    .line 40
    invoke-virtual {v2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {p0, p1, v2}, Lio/kamihama/magianative/RestClient;->postRequest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    return-object p1

    :catch_0
    move-exception p1

    .line 42
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "Error with request: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/io/IOException;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    return-object v0

    :catch_1
    move-exception p1

    .line 35
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "Error adding version: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Lorg/json/JSONException;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    return-object v0
.end method
