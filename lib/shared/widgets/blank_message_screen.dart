import 'package:flutter/material.dart';

class BlankMessageScreen extends StatelessWidget {
  final String title, description;
  final IconData icon;
  final Function? callback;
  final String? buttonTitle;
  final double? height;

  const BlankMessageScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.callback,
    this.buttonTitle,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: Column(
          /* 
          crossAxisAlignment: CrossAxisAlignment.center,
          */
          children: [
            Container(
              width: 150,
              height: 150,
              margin: const EdgeInsets.only(bottom: 50),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(100),
              ),
              //color: Colors.indigo,
              child: Center(child: Icon(icon, size: 100, color: Colors.white)),
            ),
            ?(title.isEmpty)
                ? null
                : _CustomTextLabel(
                    text: title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall!.merge(
                      TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

            SizedBox(height: 10),
            _CustomTextLabel(
              text: description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.merge(
                TextStyle(letterSpacing: 0.5, color: Color(0xde000000)),
              ),
            ),

            if (callback != null && buttonTitle != null)
              const SizedBox(height: 20),
            if (callback != null && buttonTitle != null)
              GestureDetector(
                onTap: () {
                  callback!();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: _CustomTextLabel(
                    text: buttonTitle!,
                    //softWrap: true,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const _CustomTextLabel({required this.text, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? TextStyle(color: Color(0xde000000)),
      textAlign: textAlign,
      //maxLines: maxLines,
      //overflow: overflow,
      softWrap: true,
    );
  }
}
