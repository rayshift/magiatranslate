enum BaseSceneLayerType {
    DebugMenuSceneLayer,
    DebugSelectQuestSceneLayer,
    DebugSelectStorySceneLayer,
    SoundViewerSceneLayer,
    DebugSelectMysteriesSceneLayer,
    AnimeViewerSceneLayer,
    CameraSceneLayer,
    WebSceneLayer,
    StartupSceneLayer,
    PrologueSceneLayer,
    AnotherQuestSceneLayer,
    TopSceneLayer,
    EventStoryRaidSceneLayer,
    EventBranchSceneLayer,
    EventSingleRaidSceneLayer,
    EventDungeonSceneLayer,
    EventRaidSceneLayer,
    EventPuellaHistoriaSceneLayer,
    QuestBattleSceneLayer,
    QuestUnitTestSceneLayer,
    EvolutionSceneLayer,
    MemoriaSceneLayer,
    GachaSceneLayer,
    StorySceneLayer,
    StoryViewerSceneLayer,
    Live2dViewerSceneLayer,
    MovieSceneLayer,
    DownloadSceneLayer,
    DebugSelectURLSceneLayer,
    QuestStoredDataSceneLayer,
    SendReplayDataSceneLayer,
    InputTextSceneLayer,
    SpfxViewerSceneLayer,
    LoadingSceneLayer,
    ErrorSceneLayer,
    NetworkErrorSceneLayer,
    TapSceneLayer,
    EmotionBoardSceneLayer,
    GlassTapSceneLayer,
    QuestViewerSceneLayer,
    BaseSceneLayerTypeMaxValue
};

char const* BaseSceneLayerTypeStrings[] {
    "DebugMenuSceneLayer",
    "DebugSelectQuestSceneLayer",
    "DebugSelectStorySceneLayer",
    "SoundViewerSceneLayer",
    "DebugSelectMysteriesSceneLayer",
    "AnimeViewerSceneLayer",
    "CameraSceneLayer",
    "WebSceneLayer",
    "StartupSceneLayer",
    "PrologueSceneLayer",
    "AnotherQuestSceneLayer",
    "TopSceneLayer",
    "EventStoryRaidSceneLayer",
    "EventBranchSceneLayer",
    "EventSingleRaidSceneLayer",
    "EventDungeonSceneLayer",
    "EventRaidSceneLayer",
    "EventPuellaHistoriaSceneLayer",
    "QuestBattleSceneLayer",
    "QuestUnitTestSceneLayer",
    "EvolutionSceneLayer",
    "MemoriaSceneLayer",
    "GachaSceneLayer",
    "StorySceneLayer",
    "StoryViewerSceneLayer",
    "Live2dViewerSceneLayer",
    "MovieSceneLayer",
    "DownloadSceneLayer",
    "DebugSelectURLSceneLayer",
    "QuestStoredDataSceneLayer",
    "SendReplayDataSceneLayer",
    "InputTextSceneLayer",
    "SpfxViewerSceneLayer",
    "LoadingSceneLayer",
    "ErrorSceneLayer",
    "NetworkErrorSceneLayer",
    "TapSceneLayer",
    "GlassTapSceneLayer",
    "QuestViewerSceneLayer",
    "EmotionBoardSceneLayer"
};

#if defined(__arm__)
struct BaseSceneLayerInfo {
    char unk[24];
    BaseSceneLayerType layerType;
};
#elif defined(__aarch64__)
struct BaseSceneLayerInfo {
    char unk[36];
    BaseSceneLayerType layerType;
};
#endif

enum UrlConfigResourceType {
    BaseUrl,
    TrunkUrl,
    ScenarioUrl,
    UrlConfigResourceTypeMaxValue
};

enum UrlConfigApiType {
    ApiDomainName,                // android.magi-reco.com
    ApiEndPointUrl,               // https://android.magi-reco.com
    ApiQuestNativeGet,            // https://android.magi-reco.com/magica/api/quest/native/get
    ApiQuestNativeSend,           // https://android.magi-reco.com/magica/api/quest/native/result/send
    ApiQuestNativeContinueCheck,  // https://android.magi-reco.com/magica/api/quest/native/continue/check
    ApiQuestNativeResumeCheck,    // https://android.magi-reco.com/magica/api/quest/native/resume/check
    ApiQuestNativeReplay,         // https://android.magi-reco.com/magica/api/quest/native/save/replay
    ApiMoneyProcess,              // https://android.magi-reco.com/magica/api/money/process
    ApiMoneyCreate,               // https://android.magi-reco.com/magica/api/money/create
    ApiMoneyDmmCallback,          // https://android.magi-reco.com/magica/api/money/dmm/callback
    ApiMoneyAdd,                  // https://android.magi-reco.com/magica/api/money/add
    ApiUserLogin,                 // https://android.magi-reco.com/magica/api/user/login
    ApiMoneyRecovery,             // https://android.magi-reco.com/magica/api/money/recovery
    ApiSystemNativeGetDomainPath, // https://android.magi-reco.com/magica/api/system/native/getDomainPath
    UrlConfigApiTypeMaxValue
};

enum UrlConfigChatType {
    ChatGetChatInfoPage,       // https://android.magi-reco.com/chat/GetChatInfoPage
    ChatGetChatUseInfoPage,    // https://android.magi-reco.com/chat/GetChatUseInfoPage
    ChatGetChatUserInfoPage,   // https://android.magi-reco.com/chat/GetChatUserInfoPage
    ChatGetStampInfoPage,      // https://android.magi-reco.com/chat/GetStampInfoPage
    ChatSendChatCommentPage,   // https://android.magi-reco.com/chat/SendChatCommentPage
    ChatDeleteChatCommentPage, // https://android.magi-reco.com/chat/DeleteChatCommentPage
    UrlConfigChatTypeMaxValue
};

enum UrlConfigWebType {
    WebEndPointUrl,    // https://android.magi-reco.com
    WebIndex,          // https://android.magi-reco.com/magica/index.html
    WebTopPage,        // https://android.magi-reco.com/magica/index.html#/TopPage
    WebPurchaseTop,    // https://android.magi-reco.com/magica/index.html#/PurchaseTop
    UrlConfigWebTypeMaxValue
};