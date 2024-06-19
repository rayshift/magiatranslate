.class Lio/kamihama/magianative/OptionsAllowResponse$1;
.super Ljava/util/HashMap;
.source "OptionsAllowResponse.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/kamihama/magianative/OptionsAllowResponse;->shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/util/HashMap<",
        "Ljava/lang/String;",
        "Ljava/lang/String;",
        ">;"
    }
.end annotation


# direct methods
.method constructor <init>()V
    .locals 4

    .line 74
    invoke-direct {p0}, Ljava/util/HashMap;-><init>()V

    const-string v0, "Connection"

    const-string v1, "close"

    .line 75
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Content-Type"

    const-string v1, "text/plain"

    .line 76
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 77
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    new-instance v1, Ljava/text/SimpleDateFormat;

    const-string v2, "E, dd MMM yyyy kk:mm:ss"

    sget-object v3, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-direct {v1, v2, v3}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    new-instance v2, Ljava/util/Date;

    invoke-direct {v2}, Ljava/util/Date;-><init>()V

    invoke-virtual {v1, v2}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, " GMT"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "Date"

    invoke-virtual {p0, v1, v0}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Access-Control-Allow-Origin"

    const-string v1, "https://magirecojp.cirno.name"

    .line 78
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Access-Control-Allow-Methods"

    const-string v1, "GET, POST, DELETE, PUT, OPTIONS"

    .line 79
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Access-Control-Max-Age"

    const-string v1, "600"

    .line 80
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Access-Control-Allow-Credentials"

    const-string v1, "true"

    .line 81
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Access-Control-Allow-Headers"

    const-string v1, "client-model-name,client-os-ver,client-session-id,content-type,f4s-client-ver,user-id-fba9x88mae,webview-session-id,x-platform-host,x-requested-with"

    .line 82
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "Via"

    const-string v1, "1.1 vegur"

    .line 83
    invoke-virtual {p0, v0, v1}, Lio/kamihama/magianative/OptionsAllowResponse$1;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method
