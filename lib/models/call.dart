class Call {
  String callerId, callerName, callerPic, recieverId, recieverName;
  String recieverPic, channelId;
  bool hasDialed;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.recieverId,
    this.recieverName,
    this.recieverPic,
    this.channelId,
    this.hasDialed,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'recieverId': recieverId,
      'recieverName': recieverName,
      'recieverPic': recieverPic,
      'channelId': channelId,
      'hasDialed': hasDialed,
    };
  }

  Call.fromMap(Map<String, dynamic> map) {
    callerId = map['callerId'];
    callerName = map['callerName'];
    callerPic = map['callerPic'];
    recieverId = map['recieverId'];
    recieverName = map['recieverName'];
    recieverPic = map['recieverPic'];
    channelId = map['channelId'];
    hasDialed = map['hasDialed'];
  }
}
