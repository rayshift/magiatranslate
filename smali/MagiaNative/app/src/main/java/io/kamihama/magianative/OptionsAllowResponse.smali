.class public Lio/kamihama/magianative/OptionsAllowResponse;
.super Ljava/lang/Object;
.source "OptionsAllowResponse.java"


# static fields
.field static final host:Ljava/lang/String; = "android.magi-reco.com"

.field static final proxyHost:Ljava/lang/String; = "magirecojp.cirno.name"

.field static final topPageJsPath:Ljava/lang/String; = "/magica/js/top/TopPage.js"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 32
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static buildRequest(Landroid/webkit/WebResourceRequest;Ljava/lang/String;)Lokhttp3/Request;
    .locals 4

    .line 40
    new-instance v0, Lokhttp3/Request$Builder;

    invoke-direct {v0}, Lokhttp3/Request$Builder;-><init>()V

    .line 41
    invoke-interface {p0}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v0

    .line 43
    invoke-interface {p0}, Landroid/webkit/WebResourceRequest;->getMethod()Ljava/lang/String;

    move-result-object v1

    const-string v2, "POST"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 44
    invoke-static {p1}, Lokhttp3/MediaType;->parse(Ljava/lang/String;)Lokhttp3/MediaType;

    move-result-object p1

    const-string v1, "null"

    invoke-static {p1, v1}, Lokhttp3/RequestBody;->create(Lokhttp3/MediaType;Ljava/lang/String;)Lokhttp3/RequestBody;

    move-result-object p1

    invoke-virtual {v0, p1}, Lokhttp3/Request$Builder;->post(Lokhttp3/RequestBody;)Lokhttp3/Request$Builder;

    move-result-object p1

    goto :goto_0

    .line 46
    :cond_0
    invoke-virtual {v0}, Lokhttp3/Request$Builder;->get()Lokhttp3/Request$Builder;

    move-result-object p1

    :goto_0
    const-string v0, "Accept-Encoding"

    .line 49
    invoke-virtual {p1, v0}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v1, "gzip, deflate"

    .line 50
    invoke-virtual {p1, v0, v1}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v0, "Accept-Language"

    .line 51
    invoke-virtual {p1, v0}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v1, "ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7"

    .line 52
    invoke-virtual {p1, v0, v1}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v0, "Sec-Fetch-Site"

    const-string v1, "same-origin"

    .line 53
    invoke-virtual {p1, v0, v1}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v0, "Sec-Fetch-Mode"

    const-string v1, "cors"

    .line 54
    invoke-virtual {p1, v0, v1}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    const-string v0, "Sec-Fetch-Dest"

    const-string v1, "empty"

    .line 55
    invoke-virtual {p1, v0, v1}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object p1

    .line 57
    invoke-interface {p0}, Landroid/webkit/WebResourceRequest;->getRequestHeaders()Ljava/util/Map;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_1
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Map$Entry;

    .line 58
    invoke-interface {v0}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 59
    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    const-string v2, "magirecojp.cirno.name"

    const-string v3, "android.magi-reco.com"

    invoke-virtual {v0, v2, v3}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v0

    .line 60
    invoke-virtual {p1, v1}, Lokhttp3/Request$Builder;->removeHeader(Ljava/lang/String;)Lokhttp3/Request$Builder;

    move-result-object v2

    invoke-virtual {v2, v1, v0}, Lokhttp3/Request$Builder;->addHeader(Ljava/lang/String;Ljava/lang/String;)Lokhttp3/Request$Builder;

    goto :goto_1

    .line 63
    :cond_1
    invoke-virtual {p1}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;

    move-result-object p0

    return-object p0
.end method

.method public static shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
    .locals 11

    .line 68
    invoke-interface {p1}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;

    move-result-object p0

    invoke-virtual {p0}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object p0

    .line 69
    invoke-interface {p1}, Landroid/webkit/WebResourceRequest;->getMethod()Ljava/lang/String;

    move-result-object v0

    .line 71
    invoke-static {}, Lio/kamihama/magianative/RestClient;->getUnsafeOkHttpClient()Lokhttp3/OkHttpClient;

    move-result-object v1

    .line 74
    new-instance v9, Lio/kamihama/magianative/OptionsAllowResponse$1;

    invoke-direct {v9}, Lio/kamihama/magianative/OptionsAllowResponse$1;-><init>()V

    const-string v2, "/magica/js/top/TopPage.js"

    .line 86
    invoke-virtual {p0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    const-string v3, "Content-Type"

    const-string v4, "UTF-8"

    const/16 v5, 0xc8

    const/4 v10, 0x0

    if-nez v2, :cond_2

    const-string v2, "/magica/js/top/TopPage.js?"

    invoke-virtual {p0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_0

    goto/16 :goto_1

    :cond_0
    const-string v2, "/magica/api/user/create"

    .line 140
    invoke-virtual {p0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_3

    const-string p0, "OPTIONS"

    .line 142
    invoke-virtual {v0, p0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_1

    .line 143
    new-instance p0, Landroid/webkit/WebResourceResponse;

    const-string v3, "text/plain"

    const-string v4, "UTF-8"

    const/16 v5, 0xc8

    const-string v6, "OK"

    const/4 v8, 0x0

    move-object v2, p0

    move-object v7, v9

    invoke-direct/range {v2 .. v8}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/util/Map;Ljava/io/InputStream;)V

    return-object p0

    .line 149
    :cond_1
    :try_start_0
    new-instance p0, Ljava/io/ByteArrayInputStream;

    const-string v0, "{\"resultCode\":\"error\"}"

    invoke-virtual {v0, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v0

    invoke-direct {p0, v0}, Ljava/io/ByteArrayInputStream;-><init>([B)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1

    :try_start_1
    const-string v0, "application/json; charset=utf-8"

    .line 150
    invoke-static {p1, v0}, Lio/kamihama/magianative/OptionsAllowResponse;->buildRequest(Landroid/webkit/WebResourceRequest;Ljava/lang/String;)Lokhttp3/Request;

    move-result-object p1

    invoke-virtual {v1, p1}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object p1

    invoke-interface {p1}, Lokhttp3/Call;->execute()Lokhttp3/Response;

    move-result-object p1

    .line 151
    invoke-virtual {p1}, Lokhttp3/Response;->code()I

    move-result v0

    if-ne v0, v5, :cond_3

    const-string v0, "application/json;charset=UTF-8"

    .line 152
    invoke-interface {v9, v3, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 153
    new-instance v0, Landroid/webkit/WebResourceResponse;

    const-string v3, "application/json"

    const-string v4, "UTF-8"

    const/16 v5, 0xc8

    const-string v6, "OK"

    invoke-virtual {p1}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object p1

    invoke-virtual {p1}, Lokhttp3/ResponseBody;->byteStream()Ljava/io/InputStream;

    move-result-object v8

    move-object v2, v0

    move-object v7, v9

    invoke-direct/range {v2 .. v8}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/util/Map;Ljava/io/InputStream;)V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    return-object v0

    :catch_0
    move-object v8, p0

    goto :goto_0

    :catch_1
    move-object v8, v10

    .line 157
    :goto_0
    new-instance p0, Landroid/webkit/WebResourceResponse;

    const-string v3, "application/json"

    const-string v4, "UTF-8"

    const/16 v5, 0x198

    const-string v6, "Request Timeout"

    move-object v2, p0

    move-object v7, v9

    invoke-direct/range {v2 .. v8}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/util/Map;Ljava/io/InputStream;)V

    return-object p0

    :cond_2
    :goto_1
    :try_start_2
    const-string p0, "application/javascript; charset=utf-8"

    .line 89
    invoke-static {p1, p0}, Lio/kamihama/magianative/OptionsAllowResponse;->buildRequest(Landroid/webkit/WebResourceRequest;Ljava/lang/String;)Lokhttp3/Request;

    move-result-object p0

    invoke-virtual {v1, p0}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;

    move-result-object p0

    invoke-interface {p0}, Lokhttp3/Call;->execute()Lokhttp3/Response;

    move-result-object p0

    .line 90
    invoke-virtual {p0}, Lokhttp3/Response;->code()I

    move-result p1

    if-ne p1, v5, :cond_3

    .line 91
    invoke-virtual {p0}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;

    move-result-object p0

    invoke-virtual {p0}, Lokhttp3/ResponseBody;->string()Ljava/lang/String;

    move-result-object p0

    const-string p1, "transferPop:function(){if("

    const-string v0, "transferPop:function(){(typeof g===\'object\'&&typeof g.getPageJson===\'function\'&&typeof b===\'object\'&&typeof b.userDataInitilize===\'function\'&&typeof b.closeGame===\'function\'&&(window.confirm(\"Current country code: [\"+(function(){try{return g.getPageJson().user.country;}catch(e){}})()+\"], Log out to reset country code AND id?\")?(b.userDataInitilize(),window.alert(\"Please restart game manually\"),b.closeGame()):(window.prompt(\"You may copy the id below for external transfer\",window.g_sns)))),this.origTransferPop()},origTransferPop:function(){if("

    .line 132
    invoke-virtual {p0, p1, v0}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p0

    const-string p1, ";l.has(e.user,\"id\")||g.ajaxPost(a.linkList.createUser,"

    const-string v0, ";l.has(e.user,\"id\")||(function(){try{if(typeof fetch===\'function\'&&typeof a===\'object\'&&typeof a.tapBlock===\'function\'&&typeof a.loading===\'object\'&&typeof a.loading.show===\'function\'&&typeof a.loading.hide===\'function\'){a.tapBlock(true);a.loading.show();let isSuccessful = false;let h = new Headers();const o = \"https://android.magi-reco.com\";h.append(\"Client-Os-Ver\",window.osVersion);h.append(\"X-Platform-Host\",o.replace(\"https://\",\"\"));h.append(\"User-Id-Fba9x88mae\",window.g_sns);h.append(\"Client-Model-Name\",window.modelName);h.append(\"Content-Type\",\"application/JSON\");h.append(\"Accept\",\"application/json, text/javascript, */*; q=0.01\");h.append(\"Webview-Session-Id\",window.webInitTime);h.append(\"X-Requested-With\",\"XMLHttpRequest\");h.append(\"Client-Session-Id\",window.bootCount);h.append(\"F4s-Client-Ver\",window.app_ver);h.append(\"Origin\",o);h.append(\"Sec-Fetch-Site\",\"same-origin\");h.append(\"Sec-Fetch-Mode\",\"cors\");h.append(\"Sec-Fetch-Dest\",\"empty\");h.append(\"Referer\",h+\"/magica/index.html\");h.append(\"Accept-Encoding\",\"gzip, deflate\");fetch(o+\'/magica/api/user/create\',{method:\"post\",mode:\"cors\",credentials:\"include\",body:\"null\",headers:h}).then(r=>r.text()).then(r=>{r=JSON.parse(r);(isSuccessful=r!=null&&r.resultCode===\"success\"&&r.user!=null)&&window.alert(\"Successfully obtained country code [\"+r.user.country+\"], please manually restart the app\");b.closeGame()});setTimeout(function(){if(isSuccessful)return;window.prompt(\"Please manually restart the app, or try external transfer with the id below\",window.g_sns);b.closeGame()},10000);return true;}}catch(e){};return false})()||g.ajaxPost(a.linkList.createUser,"

    .line 133
    invoke-virtual {p0, p1, v0}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object p0

    .line 135
    new-instance v8, Ljava/io/ByteArrayInputStream;

    invoke-virtual {p0, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object p0

    invoke-direct {v8, p0}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    const-string p0, "application/javascript; charset=UTF-8"

    .line 136
    invoke-interface {v9, v3, p0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 137
    new-instance p0, Landroid/webkit/WebResourceResponse;

    const-string v3, "application/javascript"

    const-string v4, "UTF-8"

    const/16 v5, 0xc8

    const-string v6, "OK"

    move-object v2, p0

    move-object v7, v9

    invoke-direct/range {v2 .. v8}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/util/Map;Ljava/io/InputStream;)V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_2

    return-object p0

    :catch_2
    :cond_3
    return-object v10
.end method
