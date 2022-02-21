enum BaseSceneLayerType {
    DebugMenuSceneLayer,
    DebugSelectQuestSceneLayer,
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
    LoadingSceneLayer,
    ErrorSceneLayer,
    NetworkErrorSceneLayer,
    TapSceneLayer,
    EmotionBoardSceneLayer,
    BaseSceneLayerTypeMaxValue
};

char const* BaseSceneLayerTypeStrings[] {
    "DebugMenuSceneLayer",
    "DebugSelectQuestSceneLayer",
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
    "LoadingSceneLayer",
    "ErrorSceneLayer",
    "NetworkErrorSceneLayer",
    "TapSceneLayer",
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