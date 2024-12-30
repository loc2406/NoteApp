class Note{
  final String title;
  final String description;
  final List<String> imgs;
  final String createdDate;
  final String color;
  final String tag;
  final bool isFavorite;
  final bool isCheckList;
  final bool isNotify;

  Note({required this.title, required this.description, required this.imgs, required this.createdDate, required this.color, required this.tag, required this.isFavorite, required this.isCheckList, required this.isNotify});

  Map<String, dynamic> toMap(){
    return {
      'title': title,
      'description': description,
      'imgs': imgs,
      'createdDate': createdDate,
      'color': color,
      'tag': tag,
      'isFavorite': isFavorite,
      'isCheckList': isCheckList,
      'isNotify': isNotify,
    };
  }

  factory Note.fromMap(Map<String, dynamic> data) {
    return Note(
        title: data['title'].toString(),
        description: data['description'].toString(),
        imgs: List<String>.from(data['imgs'] ?? []),
        createdDate: data['createdDate'].toString(),
        color: data['color'].toString(),
        tag: data['tag'].toString(),
        isFavorite: data['isFavorite'],
        isCheckList: data['isCheckList'],
        isNotify: data['isNotify'],
    );
  }
}