class Note{
  final String title;
  final String content;
  final String img;
  final String createdDate;
  final String color;
  final String type;

  Note({required this.title, required this.content, required this.img, required this.createdDate, required this.color, required this.type});

  Map<String, dynamic> toMap(){
    return {
      'title': title,
      'content': content,
      'img': img,
      'createdDate': createdDate,
      'color': color,
      'type': type,
    };
  }

  factory Note.fromMap(Map<String, dynamic> data) {
    return Note(
        title: data['title'].toString(),
        content: data['content'].toString(),
        img: data['img'].toString(),
        createdDate: data['createdDate'].toString(),
        color: data['color'].toString(),
        type: data['type'].toString(),
    );
  }
}