class EventModel {
  EventModel({
    this.id,
    this.title,
    this.description,
    this.date,
    this.time,
    this.isFeatured,
    this.createdAt,
    this.image,
  });

  EventModel.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    date = json['date'];
    time = json['time'];
    isFeatured = json['isFeatured'];
    image = json['image'];
    createdAt = json['createdAt'];
  }

  int? id;
  String? title;
  String? description;
  String? date;
  String? time;
  int? isFeatured;
  String? image;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['date'] = date;
    map['time'] = time;
    map['isFeatured'] = isFeatured;
    map['image'] = image;
    map['createdAt'] = createdAt;

    return map;
  }
}
