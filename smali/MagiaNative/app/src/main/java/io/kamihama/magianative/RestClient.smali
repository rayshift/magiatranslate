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
    .registers 1

    .prologue
    .line 47
    const-string v0, "application/json; charset=utf-8"

    .line 48
    invoke-static {v0}, Lokhttp3/MediaType;->parse(Ljava/lang/String;)Lokhttp3/MediaType;

    move-result-object v0

    sput-object v0, Lio/kamihama/magianative/RestClient;->JSON:Lokhttp3/MediaType;

    .line 47
    return-void
.end method

.method public constructor <init>()V
    .registers 3

    .prologue
    .line 24
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 25
     const-string v0, "https://walpurgisnacht.rayshift.io"

    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->Endpoint:Ljava/lang/String;

    .line 26
    const-string v0, "MagiaClientJNI"

    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->LogTag:Ljava/lang/String;

    .line 27
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "okhttp3 "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "http.agent"

    invoke-static {v1}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->UserAgent:Ljava/lang/String;

    .line 50
    invoke-static {}, Lio/kamihama/magianative/RestClient;->getUnsafeOkHttpClient()Lokhttp3/OkHttpClient;

    move-result-object v0

    iput-object v0, p0, Lio/kamihama/magianative/RestClient;->client:Lokhttp3/OkHttpClient;

    return-void
.end method

.method private static getUnsafeOkHttpClient()Lokhttp3/OkHttpClient;
    .registers 8

    .prologue
    .line 85
    const/4 v6, 0x1

    :try_start_1
    new-array v5, v6, [Ljavax/net/ssl/TrustManager;

    const/4 v6, 0x0

    new-instance v7, Lio/kamihama/magianative/RestClient$1;

    invoke-direct {v7}, Lio/kamihama/magianative/RestClient$1;-><init>()V

    aput-object v7, v5, v6

    .line 103
    .local v5, "trustAllCerts":[Ljavax/net/ssl/TrustManager;
    const-string v6, "SSL"

    invoke-static {v6}, Ljavax/net/ssl/SSLContext;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/SSLContext;

    move-result-object v3

    .line 104
    .local v3, "sslContext":Ljavax/net/ssl/SSLContext;
    const/4 v6, 0x0

    new-instance v7, Ljava/security/SecureRandom;

    invoke-direct {v7}, Ljava/security/SecureRandom;-><init>()V

    invoke-virtual {v3, v6, v5, v7}, Ljavax/net/ssl/SSLContext;->init([Ljavax/net/ssl/KeyManager;[Ljavax/net/ssl/TrustManager;Ljava/security/SecureRandom;)V

    .line 106
    invoke-virtual {v3}, Ljavax/net/ssl/SSLContext;->getSocketFactory()Ljavax/net/ssl/SSLSocketFactory;

    move-result-object v4

    .line 108
    .local v4, "sslSocketFactory":Ljavax/net/ssl/SSLSocketFactory;
    new-instance v0, Lokhttp3/OkHttpClient$Builder;

    invoke-direct {v0}, Lokhttp3/OkHttpClient$Builder;-><init>()V

    .line 109
    .local v0, "builder":Lokhttp3/OkHttpClient$Builder;
    const/4 v6, 0x0

    aget-object v6, v5, v6

    check-cast v6, Ljavax/net/ssl/X509TrustManager;

    invoke-virtual {v0, v4, v6}, Lokhttp3/OkHttpClient$Builder;->sslSocketFactory(Ljavax/net/ssl/SSLSocketFactory;Ljavax/net/ssl/X509TrustManager;)Lokhttp3/OkHttpClient$Builder;

    .line 110
    new-instance v6, Lio/kamihama/magianative/RestClient$2;

    invoke-direct {v6}, Lio/kamihama/magianative/RestClient$2;-><init>()V

    invoke-virtual {v0, v6}, Lokhttp3/OkHttpClient$Builder;->hostnameVerifier(Ljavax/net/ssl/HostnameVerifier;)Lokhttp3/OkHttpClient$Builder;

    .line 117
    invoke-virtual {v0}, Lokhttp3/OkHttpClient$Builder;->build()Lokhttp3/OkHttpClient;
    :try_end_36
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_36} :catch_38

    move-result-object v2

    .line 118
    .local v2, "okHttpClient":Lokhttp3/OkHttpClient;
    return-object v2

    .line 119
    .end local v0    # "builder":Lokhttp3/OkHttpClient$Builder;
    .end local v2    # "okHttpClient":Lokhttp3/OkHttpClient;
    .end local v3    # "sslContext":Ljavax/net/ssl/SSLContext;
    .end local v4    # "sslSocketFactory":Ljavax/net/ssl/SSLSocketFactory;
    :catch_38
    move-exception v1

    .line 120
    .local v1, "e":Ljava/lang/Exception;
    new-instance v6, Ljava/lang/RuntimeException;

    invoke-direct {v6, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw v6
.end method

.method private postRequest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 11
    .param p1, "url"    # Ljava/lang/String;
    .param p2, "json"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 53
    sget-object v5, Lio/kamihama/magianative/RestClient;->JSON:Lokhttp3/MediaType;

    invoke-static {v5, p2}, Lokhttp3/RequestBody;->create(Lokhttp3/MediaType;Ljava/lang/String;)Lokhttp3/RequestBody;

    move-result-object v0

    .line 55
    .local v0, "body":Lokhttp3/RequestBody;
    new-instance v5, Lokhttp3/Request$Builder;

    invoke-direct {v5}, Lokhttp3/Request$Builder;-><init>()V

    .line 56
    invoke-virtual {v5, p1}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v5

    .line 57
    invoke-virtual {v5, v0}, Lokhttp3/Request$Builder;->post(Lokhttp3/RequestBody;)Lokhttp3/Request$Builder;

    move-result-object v5

    const-string v6, "User-Agent"

    .line 58
    invoke-virtual {v5, v6}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v5

    const-string v6, "User-Agent"

    iget-object v7, p0, Lio/kamihama/magianative/RestClient;->UserAgent:Ljava/lang/String;

    .line 59
    invoke-virtual {v5, v6, v7}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v5

    .line 60
    invoke-virtual {v5}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;

    move-result-object v3

    .line 62
    .local v3, "request":Lokhttp3/Request;
    iget-object v5, p0, Lio/kamihama/magianative/RestClient;->client:Lokhttp3/OkHttpClient;

    invoke-virtual {v5, v3}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object v5

    invoke-interface {v5}, Lokhttp3/Call;->execute()Lokhttp3/Response;

    move-result-object v4

    .line 65
    .local v4, "response":Lokhttp3/Response;
    invoke-virtual {v4}, Lokhttp3/Response;->code()I

    move-result v5

    const/16 v6, 0x133

    if-eq v5, v6, :cond_3f

    invoke-virtual {v4}, Lokhttp3/Response;->code()I

    move-result v5

    const/16 v6, 0x134

    if-ne v5, v6, :cond_81

    .line 66
    :cond_3f
    const-string v5, "Location"

    invoke-virtual {v4, v5}, Lokhttp3/Response;->header(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 67
    .local v1, "location":Ljava/lang/String;
    if-eqz v1, :cond_81

    .line 68
    invoke-virtual {v3}, Lokhttp3/Request;->newBuilder()Lokhttp3/Request$Builder;

    move-result-object v5

    .line 69
    invoke-virtual {v5, v1}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v5

    .line 70
    invoke-virtual {v5, v0}, Lokhttp3/Request$Builder;->post(Lokhttp3/RequestBody;)Lokhttp3/Request$Builder;

    move-result-object v5

    const-string v6, "User-Agent"

    .line 71
    invoke-virtual {v5, v6}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v5

    const-string v6, "User-Agent"

    iget-object v7, p0, Lio/kamihama/magianative/RestClient;->UserAgent:Ljava/lang/String;

    .line 72
    invoke-virtual {v5, v6, v7}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v5

    .line 73
    invoke-virtual {v5}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;

    move-result-object v3

    .line 75
    iget-object v5, p0, Lio/kamihama/magianative/RestClient;->client:Lokhttp3/OkHttpClient;

    invoke-virtual {v5, v3}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object v5

    invoke-interface {v5}, Lokhttp3/Call;->execute()Lokhttp3/Response;

    move-result-object v2

    .line 76
    .local v2, "newResponse":Lokhttp3/Response;
    invoke-virtual {v2}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object v5

    if-eqz v5, :cond_7e

    invoke-virtual {v2}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object v5

    invoke-virtual {v5}, Lokhttp3/ResponseBody;->string()Ljava/lang/String;

    move-result-object v5

    .line 79
    .end local v1    # "location":Ljava/lang/String;
    .end local v2    # "newResponse":Lokhttp3/Response;
    :goto_7d
    return-object v5

    .line 76
    .restart local v1    # "location":Ljava/lang/String;
    .restart local v2    # "newResponse":Lokhttp3/Response;
    :cond_7e
    const-string v5, ""

    goto :goto_7d

    .line 79
    .end local v1    # "location":Ljava/lang/String;
    .end local v2    # "newResponse":Lokhttp3/Response;
    :cond_81
    invoke-virtual {v4}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object v5

    if-eqz v5, :cond_90

    invoke-virtual {v4}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object v5

    invoke-virtual {v5}, Lokhttp3/ResponseBody;->string()Ljava/lang/String;

    move-result-object v5

    goto :goto_7d

    :cond_90
    const-string v5, ""

    goto :goto_7d
.end method


# virtual methods
.method public GetEndpoint(I)Ljava/lang/String;
    .registers 7
    .param p1, "version"    # I

    .prologue
    .line 30
    new-instance v1, Lorg/json/JSONObject;

    invoke-direct {v1}, Lorg/json/JSONObject;-><init>()V

    .line 33
    .local v1, "jsonString":Lorg/json/JSONObject;
    :try_start_5
    const-string v2, "version"

    invoke-virtual {v1, v2, p1}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    :try_end_a
    .catch Lorg/json/JSONException; {:try_start_5 .. :try_end_a} :catch_15

    .line 40
    :try_start_a
    const-string v2, "https://walpurgisnacht.rayshift.io/api/v1/endpoint"

    invoke-virtual {v1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {p0, v2, v3}, Lio/kamihama/magianative/RestClient;->postRequest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    :try_end_13
    .catch Ljava/io/IOException; {:try_start_a .. :try_end_13} :catch_35

    move-result-object v2

    .line 43
    :goto_14
    return-object v2

    .line 34
    :catch_15
    move-exception v0

    .line 35
    .local v0, "e":Lorg/json/JSONException;
    const-string v2, "MagiaClientJNI"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Error adding version: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Lorg/json/JSONException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 36
    const-string v2, ""

    goto :goto_14

    .line 41
    .end local v0    # "e":Lorg/json/JSONException;
    :catch_35
    move-exception v0

    .line 42
    .local v0, "e":Ljava/io/IOException;
    const-string v2, "MagiaClientJNI"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Error with request: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/io/IOException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 43
    const-string v2, ""

    goto :goto_14
.end method
