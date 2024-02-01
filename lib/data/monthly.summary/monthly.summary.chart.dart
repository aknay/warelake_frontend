import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/monthly.summary/legends.dart';
import 'package:inventory_frontend/data/monthly.summary/step.calculator.dart';
import 'package:inventory_frontend/domain/monthly.summary/entities.dart';
import 'package:inventory_frontend/view/constants/colors.dart';

class GroupData {
  final int index;
  final double incoming;
  final double outgoing;

  const GroupData({required this.index, required this.incoming, required this.outgoing});

  factory GroupData.withEmpty({required int index}) {
    return GroupData(index: index, incoming: 0, outgoing: 0);
  }
}

class MonthlySummaryChart extends ConsumerStatefulWidget {
  const MonthlySummaryChart({super.key, required this.monthlySummaryList, required this.currencyCode});
  final CurrencyCode currencyCode;
  final List<MonthlySummary> monthlySummaryList;

  final Color leftBarColor = rallyGreen;
  final Color rightBarColor = rallyOrange;
  final Color avgColor = rallyPurple;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => IncomingOutGoingAmountChartState();
}

class IncomingOutGoingAmountChartState extends ConsumerState<MonthlySummaryChart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final double width = 6;

  late List<BarChartGroupData> showingBarGroups = [];

  Future<void> _startAnimation() async {
    try {
      await _animationController.forward().orCancel;
    } on TickerCanceled {
      // Animation was canceled, handle as needed
    }
  }

  late final double maxValue;

  double _clipValue({required double value, required double max}) {
    return value <= max ? value : max;
  }

  double _maxValue({required List<MonthlySummary> monthlySummaryList}) {
    final maxIncomingAmount = monthlySummaryList
        .map((element) => element.incomingAmount)
        .fold(0.0, (previousValue, element) => element > previousValue ? element : previousValue);

    final maxOutgoingAmount = monthlySummaryList
        .map((element) => element.outgoingAmount)
        .fold(0.0, (previousValue, element) => element > previousValue ? element : previousValue);

    return maxIncomingAmount > maxOutgoingAmount ? maxIncomingAmount : maxOutgoingAmount;
  }

  GroupData _getGroupData(
      {required index, required MonthYear monthYear, required List<MonthlySummary> monthlySummaryList}) {
    final monthSummaryList =
        monthlySummaryList.where((element) => element.monthYear == monthYear.toYearMonthDayString());

    return monthSummaryList.isEmpty
        ? GroupData.withEmpty(index: index)
        : GroupData(
            index: index,
            incoming: monthSummaryList.first.incomingAmount,
            outgoing: monthSummaryList.first.outgoingAmount);
  }

  @override
  void initState() {
    super.initState();
    final onlySixMonthList = [for (var i = 0; i >= -5; i--) i];
    final monthYearList = onlySixMonthList.map((e) => MonthYear.thisMonth().getDeltaMonth(e)).toList();

    final monthlySummaryList = widget.monthlySummaryList;
    final groupDataList = monthYearList
        .mapIndexed(
            (index, element) => _getGroupData(index: index, monthYear: element, monthlySummaryList: monthlySummaryList))
        .toList();

    groupDataList.sort((a, b) => b.index.compareTo(a.index));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust the duration as needed
    );
    maxValue = _maxValue(monthlySummaryList: monthlySummaryList);
    _animation = Tween<double>(begin: 0.0, end: maxValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Use a custom curve here
      ),
    );

    _animation.addListener(() {
      setState(() {
        final newValue = _animation.value;
        showingBarGroups = groupDataList
            .map((e) => makeGroupData(
                e.index, _clipValue(value: newValue, max: e.incoming), _clipValue(value: newValue, max: e.outgoing)))
            .toList();
      });
    });
    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8),
          child: LegendsListWidget(
            legends: [
              Legend('Incoming', rallyGreen),
              Legend('Outgoing', rallyOrange),
            ],
          ),
        ),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxValue,
              titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: showingBarGroups,
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color.fromARGB(255, 0, 115, 255),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;

    final mag = getMagnitude(value: maxValue);
    if (value == 0.0) {
      return Container();
    } else if (value % mag == 0) {
      text = value.toInt().toString();
    } else {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final onlySixMonthList = [for (var i = 0; i >= -5; i--) i];
    final monthYearList = onlySixMonthList.map((e) => MonthYear.thisMonth().getDeltaMonth(e)).toList();
    final titles = monthYearList.map((e) => e.toShortMonthString().toUpperCase()).toList();

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      // showingTooltipIndicators: [0, 1],
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
