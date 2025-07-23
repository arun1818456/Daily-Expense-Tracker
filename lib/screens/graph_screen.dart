import 'package:graphic/graphic.dart';
import 'package:river/exports.dart';


class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const adjustData = [
      {"type": "Email", "index": 0, "value": 120},
      {"type": "Email", "index": 1, "value": 132},
      {"type": "Email", "index": 2, "value": 101},
      {"type": "Email", "index": 3, "value": 134},
      {"type": "Email", "index": 4, "value": 90},
      {"type": "Email", "index": 5, "value": 230},
      {"type": "Email", "index": 6, "value": 210},
      {"type": "Affiliate", "index": 0, "value": 220},
      {"type": "Affiliate", "index": 1, "value": 182},
      {"type": "Affiliate", "index": 2, "value": 191},
      {"type": "Affiliate", "index": 3, "value": 234},
      {"type": "Affiliate", "index": 4, "value": 290},
      {"type": "Affiliate", "index": 5, "value": 330},
      {"type": "Affiliate", "index": 6, "value": 310},
      {"type": "Video", "index": 0, "value": 150},
      {"type": "Video", "index": 1, "value": 232},
      {"type": "Video", "index": 2, "value": 201},
      {"type": "Video", "index": 3, "value": 154},
      {"type": "Video", "index": 4, "value": 190},
      {"type": "Video", "index": 5, "value": 330},
      {"type": "Video", "index": 6, "value": 410},
      {"type": "Direct", "index": 0, "value": 320},
      {"type": "Direct", "index": 1, "value": 332},
      {"type": "Direct", "index": 2, "value": 301},
      {"type": "Direct", "index": 3, "value": 334},
      {"type": "Direct", "index": 4, "value": 390},
      {"type": "Direct", "index": 5, "value": 330},
      {"type": "Direct", "index": 6, "value": 320},
      {"type": "Search", "index": 0, "value": 320},
      {"type": "Search", "index": 1, "value": 432},
      {"type": "Search", "index": 2, "value": 401},
      {"type": "Search", "index": 3, "value": 434},
      {"type": "Search", "index": 4, "value": 390},
      {"type": "Search", "index": 5, "value": 430},
      {"type": "Search", "index": 6, "value": 420},
    ];
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    List<Expense> expenses = ref.watch(expensesProvider);

    final chartData = expenses.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return {
        'type': e.category.name,
        'index': i,
        'value': e.amount,
      };
    }).toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text('Rectangle Interval Mark')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 350,
              height: 300,
              child: Chart(
                data: adjustData,
                variables: {
                  'index': Variable(
                    accessor: (Map map) => map['index'].toString(),
                  ),
                  'type': Variable(
                    accessor: (Map map) => map['type'] as String,
                  ),
                  'value': Variable(
                    accessor: (Map map) => map['value'] as num,
                    scale: LinearScale(min: 0, max: 1800),
                  ),
                },
                marks: [
                  IntervalMark(
                    position:
                        Varset('index') * Varset('value') / Varset('type'),
                    shape: ShapeEncode(value: RectShape(labelPosition: 0.5)),
                    color: ColorEncode(
                      variable: 'type',
                      values: Defaults.colors10,
                    ),
                    label: LabelEncode(
                      encoder: (tuple) => Label(
                        tuple['value'].toString(),
                        LabelStyle(textStyle: const TextStyle(fontSize: 6)),
                      ),
                    ),
                    modifiers: [StackModifier()],
                  ),
                ],
                coord: RectCoord(
                  horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                ),
                axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
                selections: {'tap': PointSelection(variable: 'index')},
                tooltip: TooltipGuide(multiTuples: true),
                crosshair: CrosshairGuide(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
