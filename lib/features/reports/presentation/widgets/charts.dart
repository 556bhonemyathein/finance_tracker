import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// Chart building blocks shared by the dashboard and the reports screen.
///
/// They take plain data and no providers, which keeps them trivially
/// previewable and testable, and lets both screens style them identically.

/// One slice of the category breakdown.
typedef CategorySlice = ({String label, double value, Color color});

/// One day/period in a time series.
typedef SeriesPoint = ({String label, double income, double expense});

/// Income vs expense over time, as grouped bars.
///
/// Bars beat a line for discrete periods: they say "this week" rather than
/// implying a continuous quantity between the points.
class IncomeExpenseBarChart extends StatelessWidget {
  const IncomeExpenseBarChart({
    required this.points,
    required this.currencyCode,
    super.key,
    this.height = 220,
  });

  final List<SeriesPoint> points;
  final String currencyCode;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return SizedBox(height: height);

    final double maxValue = points
        .map((SeriesPoint p) => p.income > p.expense ? p.income : p.expense)
        .fold<double>(0, (double a, double b) => a > b ? a : b);
    // A flat-zero chart would divide by zero on the axis interval.
    final double top = maxValue <= 0 ? 100 : maxValue * 1.25;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: top / 4,
            getDrawingHorizontalLine: (double value) => FlLine(
              color: context.colors.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: top / 4,
                getTitlesWidget: (double value, TitleMeta meta) => Text(
                  value.toCompactCurrency(currencyCode: currencyCode),
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      points[index].label,
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.colors.inverseSurface,
              getTooltipItem:
                  (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) => BarTooltipItem(
                    rod.toY.toCurrency(currencyCode: currencyCode),
                    context.text.labelMedium!.copyWith(
                      color: context.colors.onInverseSurface,
                    ),
                  ),
            ),
          ),
          barGroups: <BarChartGroupData>[
            for (int i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: points[i].income,
                    width: 8,
                    color: context.finance.income,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: points[i].expense,
                    width: 8,
                    color: context.finance.expense,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Cumulative balance over time.
class BalanceLineChart extends StatelessWidget {
  const BalanceLineChart({
    required this.points,
    required this.currencyCode,
    super.key,
    this.height = 200,
  });

  final List<SeriesPoint> points;
  final String currencyCode;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return SizedBox(height: height);

    // Running total, so the line shows where the balance actually went rather
    // than a series of disconnected daily deltas.
    double running = 0;
    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(
          i.toDouble(),
          running += points[i].income - points[i].expense,
        ),
    ];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: (points.length / 4).clamp(1, 100).toDouble(),
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    points[index].label,
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.colors.inverseSurface,
              getTooltipItems: (List<LineBarSpot> spots) => spots
                  .map(
                    (LineBarSpot spot) => LineTooltipItem(
                      spot.y.toCurrency(currencyCode: currencyCode),
                      context.text.labelMedium!.copyWith(
                        color: context.colors.onInverseSurface,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              barWidth: 3,
              color: context.colors.primary,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    context.colors.primary.withValues(alpha: 0.28),
                    context.colors.primary.withValues(alpha: 0),
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

/// Category breakdown as a donut with an inline legend.
///
/// A donut rather than a pie: the hole carries the total, which is the number
/// people actually look for first.
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart({
    required this.slices,
    required this.currencyCode,
    super.key,
  });

  final List<CategorySlice> slices;
  final String currencyCode;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  /// Which slice is under the finger — pure presentation state.
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final double total = widget.slices.fold<double>(
      0,
      (double sum, CategorySlice s) => sum + s.value,
    );
    if (total <= 0) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        SizedBox(
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 62,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                          setState(() {
                            _touched = response?.touchedSection
                                    ?.touchedSectionIndex ??
                                -1;
                          });
                        },
                  ),
                  sections: <PieChartSectionData>[
                    for (int i = 0; i < widget.slices.length; i++)
                      PieChartSectionData(
                        value: widget.slices[i].value,
                        color: widget.slices[i].color,
                        radius: _touched == i ? 30 : 24,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              _DonutCentre(
                slices: widget.slices,
                touched: _touched,
                total: total,
                currencyCode: widget.currencyCode,
              ),
            ],
          ),
        ),
        AppSpacing.lg.gapH,
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (int i = 0; i < widget.slices.length; i++)
              _LegendChip(
                slice: widget.slices[i],
                share: widget.slices[i].value / total,
                isActive: _touched == i,
              ),
          ],
        ),
      ],
    );
  }
}

class _DonutCentre extends StatelessWidget {
  const _DonutCentre({
    required this.slices,
    required this.touched,
    required this.total,
    required this.currencyCode,
  });

  final List<CategorySlice> slices;
  final int touched;
  final double total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = touched >= 0 && touched < slices.length;
    final String label = hasSelection ? slices[touched].label : 'Total';
    final double value = hasSelection ? slices[touched].value : total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.xxs.gapH,
        Text(
          value.toCompactCurrency(currencyCode: currencyCode),
          style: context.text.titleLarge,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.slice,
    required this.share,
    required this.isActive,
  });

  final CategorySlice slice;
  final double share;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: slice.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        AppSpacing.sm.gapW,
        Text(
          '${slice.label} · ${share.toPercent()}',
          style: context.text.labelSmall?.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
