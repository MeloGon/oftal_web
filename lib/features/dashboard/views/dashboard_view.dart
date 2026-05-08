import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_provider.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dashboardProviderProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          _GreetingBanner(state: s),
          _StatsRow(state: s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(flex: 5, child: _SalesBarChart(state: s)),
              Expanded(flex: 3, child: _PaymentDonut(state: s)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(flex: 5, child: _RecentSalesList(state: s)),
              Expanded(flex: 3, child: _QuickActions(ref: ref)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

String _spanishDate() {
  const months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  const days = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  final n = DateTime.now();
  final day = days[n.weekday - 1];
  return '${day[0].toUpperCase()}${day.substring(1)}, ${n.day} de ${months[n.month - 1]} de ${n.year}';
}

Color _methodColor(String method) {
  switch (method.toLowerCase()) {
    case 'efectivo':
      return const Color(0xff16A34A);
    case 'tarjeta':
      return const Color(0xff0EA5E9);
    case 'transferencia':
      return const Color(0xff7A6BF5);
    case 'nomina':
      return const Color(0xffD97706);
    default:
      return const Color(0xff71717A);
  }
}

const _kDayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

// ─── Greeting banner ─────────────────────────────────────────────────────────

class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final name =
        state.userName.isNotEmpty ? ', ${state.userName.split(' ').first}' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7A6BF5), Color(0xff9B8EF8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  '${_greeting()}$name 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _spanishDate(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                if (state.branchName.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '📍 ${state.branchName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.bubble_chart_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _StatCard(
            label: 'Mis ventas hoy',
            value: '${state.salesToday}',
            icon: Icons.receipt_long_outlined,
            iconColor: const Color(0xff7A6BF5),
            iconBg: const Color(0xffEEECFE),
          ),
        ),
        Expanded(
          child: _StatCard(
            label: 'Ingresos hoy',
            value: state.incomeToday > 0
                ? state.incomeToday.toCurrency()
                : '—',
            icon: Icons.payments_outlined,
            iconColor: const Color(0xff16A34A),
            iconBg: const Color(0xffDCFCE7),
          ),
        ),
        Expanded(
          child: _StatCard(
            label: 'Clientes en sucursal',
            value: '${state.clientsByBranch}',
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xff0EA5E9),
            iconBg: const Color(0xffE0F2FE),
          ),
        ),
        Expanded(
          child: _StatCard(
            label: 'Sucursal',
            value: state.branchName.isEmpty ? '—' : state.branchName,
            icon: Icons.store_outlined,
            iconColor: const Color(0xff10B981),
            iconBg: const Color(0xffD1FAE5),
            smallValue: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.smallValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: smallValue ? 18 : 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xff18181B),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sales bar chart ─────────────────────────────────────────────────────────

class _SalesBarChart extends StatelessWidget {
  const _SalesBarChart({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final data = state.salesByDay;
    final isEmpty = data.isEmpty;

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text(
            'Ventas últimos 7 días',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff18181B),
            ),
          ),
          SizedBox(
            height: 220,
            child: isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xff7A6BF5),
                    ),
                  )
                : _buildChart(data),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, int> data) {
    final entries = data.entries.toList();
    final maxVal =
        entries.map((e) => e.value).fold(0, (a, b) => max(a, b)).toDouble();
    final maxY = max(maxVal + 1, 3.0);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: const Color(0xff7A6BF5),
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: const Color(0xffF4F4F5),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                final dt = DateTime.tryParse(entries[idx].key);
                final label =
                    dt != null ? _kDayLabels[dt.weekday - 1] : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff71717A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: maxY > 10 ? (maxY / 5).roundToDouble() : 1,
              getTitlesWidget: (value, meta) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff71717A),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 10 ? (maxY / 5).roundToDouble() : 1,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xffF4F4F5), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff18181B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Payment donut ────────────────────────────────────────────────────────────

class _PaymentDonut extends StatelessWidget {
  const _PaymentDonut({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final methods = state.paymentsByMethod;

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text(
            'Métodos de pago hoy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff18181B),
            ),
          ),
          SizedBox(
            height: 220,
            child: methods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 32,
                          color: Colors.grey.shade300,
                        ),
                        Text(
                          'Sin pagos hoy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sections: methods.entries.map((e) {
                                  return PieChartSectionData(
                                    value: e.value,
                                    color: _methodColor(e.key),
                                    title: '',
                                    radius: 46,
                                  );
                                }).toList(),
                                centerSpaceRadius: 52,
                                sectionsSpace: 2,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.incomeToday.toCurrency(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff18181B),
                                  ),
                                ),
                                Text(
                                  'total',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: methods.entries.map((e) {
                          final pct =
                              (e.value / state.incomeToday * 100)
                                  .toStringAsFixed(0);
                          return Row(
                            spacing: 6,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _methodColor(e.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(e.key),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff18181B),
                                    ),
                                  ),
                                  Text(
                                    '$pct%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─── Recent sales ─────────────────────────────────────────────────────────────

class _RecentSalesList extends ConsumerWidget {
  const _RecentSalesList({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimas ventas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff18181B),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(appRouterProvider).go(RouterName.salesHistory),
                child: const Text(
                  'Ver todas →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff7A6BF5),
                  ),
                ),
              ),
            ],
          ),
          if (state.recentSales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Sin ventas recientes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentSales.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xffF4F4F5)),
              itemBuilder: (context, i) =>
                  _SaleRow(sale: state.recentSales[i]),
            ),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale});
  final SalesModel sale;

  @override
  Widget build(BuildContext context) {
    final isPaid = (sale.rest ?? 0) == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xff16A34A)
                  : const Color(0xffD97706),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sale.patient ?? '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xff18181B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            sale.date ?? '',
            style: const TextStyle(fontSize: 11, color: Color(0xff71717A)),
          ),
          const SizedBox(width: 12),
          Text(
            (sale.totalWithDiscount ?? sale.total)?.toCurrency() ?? '—',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff18181B),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xffDCFCE7)
                  : const Color(0xffFFF3CD),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isPaid ? 'C' : 'P',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isPaid
                    ? const Color(0xff16A34A)
                    : const Color(0xffD97706),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff18181B),
            ),
          ),
          _ActionButton(
            icon: Icons.point_of_sale_outlined,
            label: 'Nueva venta',
            color: const Color(0xff7A6BF5),
            bg: const Color(0xffEEECFE),
            onTap: () => ref.read(appRouterProvider).go(RouterName.sell),
          ),
          _ActionButton(
            icon: Icons.manage_search_outlined,
            label: 'Buscar paciente',
            color: const Color(0xff0EA5E9),
            bg: const Color(0xffE0F2FE),
            onTap: () =>
                ref.read(appRouterProvider).go(RouterName.searchPatient),
          ),
          _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Historial de ventas',
            color: const Color(0xff10B981),
            bg: const Color(0xffD1FAE5),
            onTap: () =>
                ref.read(appRouterProvider).go(RouterName.salesHistory),
          ),
          _ActionButton(
            icon: Icons.person_add_outlined,
            label: 'Agregar paciente',
            color: const Color(0xffD97706),
            bg: const Color(0xffFEF3C7),
            onTap: () =>
                ref.read(appRouterProvider).go(RouterName.addPatient),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? widget.bg : const Color(0xffFAFAFA),
            border: Border.all(
              color: _hovered ? widget.color.withValues(alpha: 0.4) : const Color(0xffE4E4E7),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            spacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon, size: 15, color: widget.color),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _hovered ? widget.color : const Color(0xff3F3F46),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: _hovered ? widget.color : const Color(0xffA1A1AA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
