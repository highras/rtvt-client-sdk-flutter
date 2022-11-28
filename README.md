### flutter-rtvt-sdk 使用文档
- [版本支持](#版本支持)
- [接口说明](#接口说明)

### 版本支持
- 最低支持Android版本为5.0
- IOS版本为 10


##  接口说明
/**登录
 * @param key 项目密钥
 * @param endpoint 链接地址
 * @param pid 项目id
 * @param RtvtDelegate 翻译推送的回调对象
 * @param success 登录成功回调
 * @param fail 登录失败回调
 */
void login(String key, String endpoint, int pid, RtvtDelegate delegate,
void Function() success,
void Function(int errorCode, String errorEx) fail) 

/**开始翻译 获取流id
* @param asrResult 是否需要识别结果
* @param srcLanguage 源语言
* @param destLanguage 目标语言
* @param success 成功回调
* @param fail 失败回调
  */
void getStreamId(bool asrResult, String srcLanguage, String destLanguage, void Function(int streamId) success, void Function(int errorCode, String errorEx) fail) 

/**结束翻译
* @param streamId 翻译流id
* @param lastSeq 最后一个语音序号
* @param success 成功回调
* @param fail 失败回调
  */
void endTranslateWithStreamId(int streamId, int lastSeq, void Function() success, void Function(int errorCode, String errorEx) fail)

/**发送语音片段
* @param streamId 翻译流id
* @param pcmData pcm数据
* @param seq 语音片段序号
* @param ts 发送的时间戳
* @param success 成功回调
* @param fail 失败回调
  */
void sendPcmData(int streamId, Uint8List pcmData, int seq, int ts, void Function() success, void Function(int errorCode, String errorEx) fail)


/**
关闭语音翻译
**/
void close() 