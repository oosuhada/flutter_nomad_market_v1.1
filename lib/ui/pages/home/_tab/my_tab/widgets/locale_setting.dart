import 'package:flutter/material.dart';
import 'package:flag/flag.dart';

class CommonWidgets {
  static PreferredSizeWidget commonAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  static Widget confirmButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required Color color,
    String text = '확인',
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class GenericSettingPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(String) onSelect;
  final String? initialSelection;

  const GenericSettingPage({
    Key? key,
    required this.title,
    required this.items,
    required this.onSelect,
    this.initialSelection,
  }) : super(key: key);

  @override
  _GenericSettingPageState createState() => _GenericSettingPageState();
}

class _GenericSettingPageState extends State<GenericSettingPage> {
  late String selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initialSelection ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonWidgets.commonAppBar(context, widget.title),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedItem = item['name'];
                      widget.onSelect(item['name']);
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Flag.fromString(
                            item['flag'],
                            height: 40,
                            width: 40,
                            borderRadius: 25,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 21),
                        Expanded(
                          child: Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 18,
                              color: selectedItem == item['name']
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.purple.shade900
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ),
                        if (selectedItem == item['name'])
                          Icon(
                            Icons.check,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.purple.shade900,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          CommonWidgets.confirmButton(
            context: context,
            onPressed: selectedItem.isNotEmpty
                ? () {
                    Navigator.pop(context, selectedItem);
                  }
                : null,
            color:
                selectedItem.isNotEmpty ? Colors.purple.shade900 : Colors.grey,
            text: '확인',
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
