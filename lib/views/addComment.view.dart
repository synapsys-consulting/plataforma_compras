import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
class _Comment {
  String temporalComment;
}
class AddComment extends StatefulWidget {
  final String comment;
  AddComment(this.comment);
  @override
  AddCommentState createState() {
    return AddCommentState();
  }
}
class AddCommentState extends State<AddComment> {
  _Comment _commentOut = new _Comment();
  @override
  void initState() {
    super.initState();
    _commentOut.temporalComment = widget.comment;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset('assets/images/leftArrow.png'),
            onPressed: (){
              Navigator.pop (context, _commentOut.temporalComment);
            }
        ),
      ),
      body: ResponsiveWidget (
        smallScreen: _SmallScreen (widget.comment, _commentOut),
        largeScreen: _LargeScreen (widget.comment, _commentOut),
      ),
    );
  }
}
class _SmallScreen extends StatefulWidget {
  final String comment;
  final _Comment commentOut;
  _SmallScreen(this.comment, this.commentOut);
  @override
  _SmallScreenState createState() {
    return _SmallScreenState();
  }
}
class _SmallScreenState extends State<_SmallScreen> {
  final TextEditingController _textCommentIntroducedByUser = TextEditingController();
  int _numCharacters = 0;
  @override
  void initState() {
    super.initState();
    _textCommentIntroducedByUser.text = widget.comment;
    _numCharacters = _textCommentIntroducedByUser.text.length;
    // Start listening to changes.
    _textCommentIntroducedByUser.addListener(_textFieldContentProcessor);
  }
  void _textFieldContentProcessor() {
    setState(() {
      _numCharacters = _textCommentIntroducedByUser.text.length;
    });
    widget.commentOut.temporalComment = _textCommentIntroducedByUser.text;
  }
  @override
  void dispose() {
    _textCommentIntroducedByUser.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea (
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container (
            width: constraints.maxWidth,
            height: constraints.maxHeight / 2,
            padding: EdgeInsets.fromLTRB (24.0, 24.0, 24.0, 24.0),
            child: TextField (
              controller: _textCommentIntroducedByUser,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              minLines: null,
              maxLines: null,
              expands: true,
              decoration: InputDecoration (
                hintText: 'Introduce tu comentario',
                counterText: _numCharacters.toString() + ' caracteres',
              ),
            ),
          );
        },
      )
    );
  }
}
class _LargeScreen extends StatefulWidget {
  final String comment;
  final _Comment commentOut;
  _LargeScreen (this.comment, this.commentOut);
  @override
  _LargeScreenState createState() {
    return _LargeScreenState();
  }
}
class _LargeScreenState extends State<_LargeScreen> {
  final TextEditingController _textCommentIntroducedByUser = TextEditingController();
  int _numCharacters = 0;
  void initState() {
    super.initState();
    _textCommentIntroducedByUser.text = widget.comment;
    _numCharacters = _textCommentIntroducedByUser.text.length;
    // Start listening to changes.
    _textCommentIntroducedByUser.addListener(_textFieldContentProcessor);
  }
  void _textFieldContentProcessor() {
    setState(() {
      _numCharacters = _textCommentIntroducedByUser.text.length;
    });
    widget.commentOut.temporalComment = _textCommentIntroducedByUser.text;
  }
  @override
  void dispose() {
    _textCommentIntroducedByUser.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea (
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container (
              width: constraints.maxWidth,
              height: constraints.maxHeight / 2,
              padding: EdgeInsets.fromLTRB (24.0, 24.0, 24.0, 24.0),
              child: TextField (
                controller: _textCommentIntroducedByUser,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                minLines: null,
                maxLines: null,
                expands: true,
                decoration: InputDecoration (
                  hintText: 'Introduce tu comentario',
                  counterText: _numCharacters.toString() + ' caracteres',
                ),
              ),
            );
          },
        )
    );
  }
}
