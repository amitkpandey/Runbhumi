import 'package:Runbhumi/models/Teams.dart';
import 'package:Runbhumi/models/message.dart';
import 'package:Runbhumi/services/chatroomServices.dart';
import 'package:Runbhumi/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamConversation extends StatefulWidget {
  final Teams data;
  TeamConversation({@required this.data});
  @override
  _TeamConversationState createState() => _TeamConversationState();
}

class _TeamConversationState extends State<TeamConversation> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController _controller = ScrollController();
  addMessage() {
    //adding the message typed by the user
    if (messageEditingController.text.trim().isNotEmpty) {
      ChatroomService().sendNewMessageTeam(
          DateTime.now(),
          Constants.prefs.getString('userId'),
          messageEditingController.text.trim(),
          Constants.prefs.getString('name'),
          widget.data.teamId);
      setState(() {
        messageEditingController.text = "";
      });
    }
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  Widget chatMessages() {
    //displaying previous chats
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                controller: _controller,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  Message data =
                      new Message.fromJson(snapshot.data.documents[index]);
                  return MessageTile(
                    //decides who sent the message and accordingly aligns the text
                    message: data.message,
                    sendByMe:
                        Constants.prefs.getString('userId') == data.sentby,
                    sentByName: data.sentByName,
                    dateTime: data.dateTime,
                  );
                })
            : Center(
                child: Container(
                  child: Text("Start taliking"),
                ),
              );
      },
    );
  }

  @override
  void initState() {
    ChatroomService().getTeamMessages(widget.data.teamId).then((value) {
      setState(() {
        chats = value;
      });
    });
    super.initState();
    Future.delayed(Duration(milliseconds: 400), () {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    String sportIcon;
    // IconData sportIcon;
    switch (widget.data.sport) {
      case "Volleyball":
        sportIcon = "assets/icons8-volleyball-96.png";
        break;
      case "Basketball":
        // sportIcon = Icons.sports_basketball;
        sportIcon = "assets/icons8-basketball-96.png";
        break;
      case "Cricket":
        sportIcon = "assets/icons8-cricket-96.png";
        break;
      case "Football":
        sportIcon = "assets/icons8-soccer-ball-96.png";
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(sportIcon),
              ),
              SizedBox(
                width: 8,
              ),
              Text(widget.data.teamName),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ChatSchedule(
              //             chatRoomId: widget.data.teamId,
              //             usersNames: widget.usersNames,
              //             users: widget.users,
              //             usersPics: widget.usersPics)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.add_circle),
            ),
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: chatMessages(),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onTap: () {
                          _controller
                              .jumpTo(_controller.position.maxScrollExtent);
                        },
                        controller: messageEditingController,
                        decoration: InputDecoration(
                            hintText: "Message ...",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          addMessage();
                        },
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String sentByName; //Sent By (Unused till now)
  final DateTime dateTime; //Time (Unused till now)
  //TODO: Use the dataTime to show time and sentBy to show who's message
  //sendByMe boolean to check if the currentuser sent the message before.

  MessageTile(
      {@required this.message,
      @required this.sendByMe,
      @required this.sentByName,
      @required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
          color: sendByMe
              ? Color(0xff393e46).withOpacity(0.8)
              : Color(0xff00adb5).withOpacity(0.8),
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400)),
      ),
    );
  }
}
