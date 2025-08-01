DROP TABLE IF EXISTS ai_chat_conversation;
CREATE TABLE ai_chat_conversation
(
    id             BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '对话记录的唯一标识，自增主键',
    user_id        BIGINT  NULL COMMENT '发起对话的用户编号，关联 AdminUserDO 的 userId 字段',
    title          VARCHAR(255)    DEFAULT '新对话' COMMENT '对话的标题，默认由系统自动生成，可用户手动修改',
    pinned         TINYINT ( 1 ) COMMENT '是否将该对话置顶，1 表示置顶，0 表示不置顶',
    pinned_time    TIMESTAMP COMMENT '对话被置顶的时间',
    role_id        BIGINT COMMENT '角色编号，关联 AiChatRoleDO 的 getId() 字段',
    knowledge_id   BIGINT COMMENT '知识库编号，关联 AiKnowledgeDO 的 getId() 字段',
    model_id       BIGINT COMMENT '模型编号，关联 AiChatModelDO 的 getId() 字段',
    model          VARCHAR(255) COMMENT '模型标志',
    system_message longtext COMMENT '角色设定信息，存储角色的相关信息',
    temperature    DOUBLE COMMENT '温度参数，用于调整生成回复的随机性和多样性，范围在 0 到 1 之间',
    max_tokens     INT COMMENT '单条回复允许的最大 Token 数量',
    max_contexts   INT COMMENT '上下文允许的最大消息数量',
    `create_time`  datetime COMMENT '创建时间',
    `update_time`  datetime COMMENT '最后更新时间',
    `creator`      VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`      VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`      TINYINT ( 1 ) DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`    BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT 'AI Chat 对话信息表';
DROP TABLE IF EXISTS ai_chat_message;
CREATE TABLE ai_chat_message
(
    id              BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为每条聊天记录的唯一标识符，自增主键',
    conversation_id BIGINT  NULL COMMENT '对话编号，关联 AiChatConversationDO 的 getId() 字段',
    reply_id        BIGINT COMMENT '回复消息编号，关联自身 id 字段，大模型回复的消息编号，用于“问答”的关联',
    type            VARCHAR(255) COMMENT '消息类型，也等价于 OpenAPI 的 role 字段',
    user_id         BIGINT  NULL COMMENT '用户编号，关联 AdminUserDO 的 userId 字段',
    role_id         BIGINT COMMENT '角色编号，关联 AiChatRoleDO 的 getId() 字段',
    segment_ids     JSON COMMENT '段落编号数组，存储 Long 类型列表，关联 AiKnowledgeSegmentDO 的 getId() 字段',
    model           VARCHAR(255) COMMENT '模型标志',
    model_id        BIGINT COMMENT '模型编号，关联 AiChatModelDO 的 getId() 字段',
    content         longtext COMMENT '聊天内容',
    use_context     TINYINT ( 1 ) COMMENT '是否携带上下文，1 表示携带，0 表示不携带',
    `create_time`   datetime COMMENT '创建时间',
    `update_time`   datetime COMMENT '最后更新时间',
    `creator`       VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`       VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`       TINYINT ( 1 ) DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`     BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT 'AI Chat 消息表';;
DROP TABLE IF EXISTS ai_image;
CREATE TABLE ai_image
(
    id            BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    user_id       BIGINT  NULL COMMENT '用户编号，关联 AdminUserRespDTO 的 getId()',
    prompt        longtext COMMENT '用于生成图像的提示词',
    platform      VARCHAR(255) COMMENT '平台，使用枚举 cn.tdx.framework.ai.core.enums.AiPlatformEnum 表示',
    model         VARCHAR(255) COMMENT '模型，冗余存储 AiChatModelDO 的 getModel() 的信息',
    width         INT COMMENT '生成图片的宽度',
    height        INT COMMENT '生成图片的高度',
    status        INT COMMENT '生成状态，使用枚举 AiImageStatusEnum 表示',
    finish_time   TIMESTAMP COMMENT '完成图像生成的时间',
    error_message VARCHAR(255) COMMENT '图像生成过程中出现的错误信息',
    pic_url       VARCHAR(255) COMMENT '生成的图片的存储地址',
    public_status TINYINT ( 1 ) COMMENT '是否公开，1 表示公开，0 表示不公开',
    options       JSON COMMENT '绘制参数，存储不同平台（如 OpenAiImageOptions、StabilityAiImageOptions）的参数，使用 JSON 格式存储',
    buttons       JSON COMMENT 'MidjourneyApi 的 Button 列表，使用 JSON 格式存储',
    task_id       VARCHAR(255) COMMENT '任务编号，对于 midjourney proxy 表示关联的 task id',
    `create_time` datetime COMMENT '创建时间',
    `update_time` datetime COMMENT '最后更新时间',
    `creator`     VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`     VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`     bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT 'AI 绘画';
DROP TABLE IF EXISTS ai_knowledge;
CREATE TABLE ai_knowledge
(
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    user_id               BIGINT  NULL COMMENT '用户编号，关联 AdminUserDO 的 userId 字段',
    name                  VARCHAR(255) COMMENT '知识库名称',
    description           longtext COMMENT '知识库的详细描述',
    visibilityPermissions JSON COMMENT '可见权限，存储可见用户的编号列表，-1 表示所有人可见，其他为各自用户编号',
    model_id              BIGINT COMMENT '嵌入模型编号',
    model                 VARCHAR(255) COMMENT '模型标识',
    topK                  INT COMMENT 'topK 参数，用于某种计算或筛选操作，具体取决于业务逻辑',
    similarity_threshold  DOUBLE COMMENT '相似度阈值，用于衡量相似度，取值范围通常在 0 到 1 之间',
    status                INT COMMENT '状态，使用枚举 CommonStatusEnum 表示，可能表示知识库的不同状态',
    `create_time`         datetime COMMENT '创建时间',
    `update_time`         datetime COMMENT '最后更新时间',
    `creator`             VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`             VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`             TINYINT ( 1 ) DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 知识库信息表';
DROP TABLE IF EXISTS ai_knowledge_document;
CREATE TABLE ai_knowledge_document
(
    id                        BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    knowledge_id              BIGINT  NULL COMMENT '知识库编号，关联 AiKnowledgeDO 的 getId()',
    name                      VARCHAR(255) COMMENT '文件名称',
    content                   longtext COMMENT '文件的具体内容',
    url                       VARCHAR(255) COMMENT '文件的 URL 地址',
    tokens                    INT COMMENT '文档的 token 数量，用于存储文档中 token 的数量',
    word_count                INT COMMENT '文档的字符数，用于存储文档中字符的数量',
    default_segment_tokens    INT COMMENT '每个文本块的目标 token 数，用于分块操作时设定每个文本块的目标 token 数量',
    min_segment_word_count    INT COMMENT '每个文本块的最小字符数，用于分块操作时设定每个文本块的最小字符数量',
    min_chunk_length_to_embed INT COMMENT '低于此值的块会被丢弃，用于分块操作时设定丢弃块的最小长度阈值',
    max_num_segments          INT COMMENT '最大块数，用于分块操作时设定最大的块数',
    keep_separator            TINYINT ( 1 ) COMMENT '分块是否保留分隔符，1 表示保留，0 表示不保留',
    slice_status              INT COMMENT '切片状态，使用枚举 AiKnowledgeDocumentStatusEnum 表示，可能表示文档切片的不同状态',
    status                    INT COMMENT '状态，使用枚举 CommonStatusEnum 表示，可能表示文档的不同状态',
    `create_time`             datetime COMMENT '创建时间',
    `update_time`             datetime COMMENT '最后更新时间',
    `creator`                 VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`                 VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`                 TINYINT ( 1 ) DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`               BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 知识库文档信息表';
DROP TABLE IF EXISTS ai_knowledge_segment;
CREATE TABLE ai_knowledge_segment
(
    id            BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    vector_id     VARCHAR(255) COMMENT '向量库的编号',
    knowledge_id  BIGINT  NULL COMMENT '知识库编号，关联 AiKnowledgeDO 的 getId()',
    document_id   BIGINT  NULL COMMENT '文档编号，关联 AiKnowledgeDocumentDO 的 getId()',
    content       longtext COMMENT '切片内容，存储知识库文档的切片部分的具体内容',
    word_count    INT COMMENT '字符数，存储切片内容的字符数量',
    tokens        INT COMMENT 'token 数量，存储切片内容的 token 数量',
    status        INT COMMENT '状态，使用枚举 CommonStatusEnum 表示，可能表示该分段的不同状态',
    `create_time` datetime COMMENT '创建时间',
    `update_time` datetime COMMENT '最后更新时间',
    `creator`     VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`     VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`     bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 知识库文档分段信息表';
DROP TABLE IF EXISTS ai_mind_map;
CREATE TABLE ai_mind_map
(
    id                BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    user_id           BIGINT  NULL COMMENT '用户编号，关联 AdminUserDO 的 userId 字段',
    platform          VARCHAR(255) COMMENT '平台，使用枚举 AiPlatformEnum 表示',
    model             VARCHAR(255) COMMENT '模型信息',
    prompt            longtext COMMENT '生成内容的提示信息',
    generated_content longtext COMMENT '生成的具体内容，可能是较长的文本信息',
    error_message     longtext COMMENT '在生成过程中出现的错误信息，存储可能出现的错误描述',
    `create_time`     datetime COMMENT '创建时间',
    `update_time`     datetime COMMENT '最后更新时间',
    `creator`         VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`         VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`         bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`       BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 思维导图信息表';
DROP TABLE IF EXISTS ai_api_key;
CREATE TABLE ai_api_key
(
    id            BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    name          VARCHAR(255) COMMENT '名称，用于标识该 API 密钥的名称',
    api_key       VARCHAR(255) COMMENT '密钥，存储 API 访问所需的密钥信息',
    platform      VARCHAR(255) COMMENT '平台，使用枚举 AiPlatformEnum 表示，标识该 API 密钥所属的平台',
    url           VARCHAR(255) COMMENT 'API 地址，存储 API 的网络地址',
    status        INT COMMENT '状态，使用枚举 CommonStatusEnum 表示，可能表示该 API 密钥的不同状态',
    `create_time` datetime COMMENT '创建时间',
    `update_time` datetime COMMENT '最后更新时间',
    `creator`     VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`     VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`     bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI API 密钥信息表';
DROP TABLE IF EXISTS ai_chat_model;
CREATE TABLE ai_chat_model
(
    id            BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，使用序列生成主键',
    key_id        BIGINT NOT NULL COMMENT 'API 秘钥编号，关联 AiApiKeyDO 的 getId()',
    NAME          VARCHAR(255) COMMENT '模型名称，用于标识该聊天模型的名称',
    model         VARCHAR(255) COMMENT '模型标志，可能是该聊天模型的唯一标识符或特定标志',-- 平台，使用枚举 AiPlatformEnum 表示
    platform      VARCHAR(255) COMMENT '平台，使用枚举 AiPlatformEnum 表示，标识该聊天模型所属的平台',-- 排序值
    sort          INT COMMENT '排序值，用于对聊天模型进行排序，数值越小排序越靠前',
    status        INT COMMENT '状态，使用枚举 CommonStatusEnum 表示，可能表示该聊天模型的不同状态',
    temperature   DOUBLE PRECISION COMMENT '温度参数，用于调整生成回复的随机性和多样性，范围在 0 到 1 之间',
    max_tokens    INT COMMENT '单条回复的最大 Token 数量，限制该聊天模型生成回复的最大 Token 数量',
    max_contexts  INT COMMENT '上下文的最大 Message 数量，限制该聊天模型的上下文最大消息数量',
    `create_time` datetime COMMENT '创建时间',
    `update_time` datetime COMMENT '最后更新时间',
    `creator`     VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`     VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`     bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT 'AI 聊天模型信息表';
DROP TABLE IF EXISTS ai_chat_role;
CREATE TABLE ai_chat_role
(
    id             BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    name           VARCHAR(255) COMMENT '角色名称，用于标识该聊天角色的名称',
    avatar         VARCHAR(255) COMMENT '角色头像，存储该聊天角色的头像信息，可能是头像的 URL 或存储路径',
    category       VARCHAR(255) COMMENT '角色分类，对角色进行分类的信息',
    description    longtext COMMENT '角色描述，对该聊天角色的详细描述信息',
    system_message longtext COMMENT '角色设定，存储该聊天角色的设定信息',
    user_id        BIGINT  NULL COMMENT '用户编号，关联 AdminUserDO 的 userId 字段',
    model_id       BIGINT COMMENT '模型编号，关联 AiChatModelDO 的 getId() 字段',
    public_status  TINYINT ( 1 ) COMMENT '是否公开，1 表示公开（由管理员在【角色管理】创建），0 表示私有（由个人在【我的角色】创建）',
    sort           INT COMMENT '排序值，用于对聊天角色进行排序，数值越小排序越靠前',
    status         INT COMMENT '状态，使用枚举 CommonStatusEnum 表示，可能表示该聊天角色的不同状态',
    `create_time`  datetime COMMENT '创建时间',
    `update_time`  datetime COMMENT '最后更新时间',
    `creator`      VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`      VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`      TINYINT ( 1 ) DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`    BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 聊天角色信息表';
DROP TABLE IF EXISTS ai_music;
CREATE TABLE ai_music
(
    id            BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    user_id       BIGINT  NULL COMMENT '用户编号，关联 AdminUserDO 的 userId 字段',
    title         VARCHAR(255) COMMENT '音乐的名称',
    lyric         longtext COMMENT '音乐的歌词内容',
    image_url     VARCHAR(255) COMMENT '音乐的图片地址，可能是封面图片的存储地址',
    audio_url     VARCHAR(255) COMMENT '音乐的音频文件存储地址',
    video_url     VARCHAR(255) COMMENT '音乐的视频文件存储地址（如果有）',
    status        INT COMMENT '音乐状态，使用枚举 AiMusicStatusEnum 表示，可能表示音乐的不同状态',
    generate_mode INT COMMENT '生成模式，使用枚举 AiMusicGenerateModeEnum 表示，可能表示音乐的不同生成模式',
    description   longtext COMMENT '对音乐的描述信息',
    platform      VARCHAR(255) COMMENT '平台，使用枚举 AiPlatformEnum 表示，标识该音乐所属的平台',
    model         VARCHAR(255) COMMENT '模型信息，可能表示用于生成音乐的模型',
    tags          JSON COMMENT '音乐风格标签，存储音乐的风格标签列表，使用 JSON 格式存储',
    duration      DOUBLE COMMENT '音乐的时长，以秒为单位',
    public_status TINYINT ( 1 ) COMMENT '是否公开，1 表示公开，0 表示不公开',
    task_id       VARCHAR(255) COMMENT '任务编号，可能是生成音乐的任务编号',
    errorMessage  longtext COMMENT '生成音乐过程中出现的错误信息',
    `create_time` datetime COMMENT '创建时间',
    `update_time` datetime COMMENT '最后更新时间',
    `creator`     VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`     VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`     bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 音乐信息表';
DROP TABLE IF EXISTS ai_write;
CREATE TABLE ai_write
(-- 编号，自增主键
    id                BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '编号，作为该表的唯一标识符，自增主键',
    user_id           BIGINT NULL COMMENT '用户编号，关联 AdminUserDO 的 userId 字段',
    type              INT COMMENT '写作类型，使用枚举 AiWriteTypeEnum 表示，可能表示不同的写作类型',
    platform          VARCHAR(255) COMMENT '平台，使用枚举 AiPlatformEnum 表示，标识该写作任务所属的平台',
    model             VARCHAR(255) COMMENT '模型信息，可能表示用于写作的模型',
    prompt            longtext COMMENT '生成内容提示，为写作任务提供的初始提示信息',
    generated_content longtext COMMENT '生成的内容，存储 AI 生成的写作内容',
    original_content  longtext COMMENT '原文，可能是写作任务的原始内容或参考内容',
    length            INT COMMENT '长度提示词，使用字典 cn.tdx.module.ai.enums.DictTypeConstants#AI_WRITE_LENGTH 表示，用于指定写作内容的长度',
    format            INT COMMENT '格式提示词，使用字典 cn.tdx.module.ai.enums.DictTypeConstants#AI_WRITE_FORMAT 表示，用于指定写作内容的格式',
    tone              INT COMMENT '语气提示词，使用字典 cn.tdx.module.ai.enums.DictTypeConstants#AI_WRITE_TONE 表示，用于指定写作内容的语气',
    language          INT COMMENT '语言提示词，使用字典 cn.tdx.module.ai.enums.DictTypeConstants#AI_WRITE_LANGUAGE 表示，用于指定写作内容的语言',
    error_message     longtext COMMENT '错误信息，存储在写作过程中出现的错误信息',
    `create_time`     datetime COMMENT '创建时间',
    `update_time`     datetime COMMENT '最后更新时间',
    `creator`         VARCHAR(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`         VARCHAR(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`         bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`       BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号'
) COMMENT = 'AI 写作信息表';

INSERT INTO `tdx_cloud`.`ai_api_key`(`id`, `name`, `api_key`, `platform`, `url`, `status`, `create_time`, `update_time`, `creator`, `updater`, `deleted`, `tenant_id`) VALUES (1, '郑文杰的通义千问key', 'sk-5e3aff51899e47558c979c3d68ff5457', 'TongYi', 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation', 0, '2025-01-16 15:53:06', '2025-01-16 16:27:37', '1', '1', b'0', 1);
INSERT INTO `tdx_cloud`.`ai_chat_model`(`id`, `key_id`, `NAME`, `model`, `platform`, `sort`, `status`, `temperature`, `max_tokens`, `max_contexts`, `create_time`, `update_time`, `creator`, `updater`, `deleted`, `tenant_id`) VALUES (1, 1, 'qwen-plus', 'qwen-plus', 'TongYi', 0, 0, 0.85, 2, 200, '2025-01-16 16:00:15', '2025-01-16 16:51:14', '1', '1', b'0', 1);

