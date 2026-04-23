import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import '../../sigma_theme.dart';
import '../widgets/portal_shell.dart';
import '../widgets/portal_widgets.dart';

import 'package:intl/intl.dart' show DateFormat;

class PortalAsistenciaScreen extends StatelessWidget {
  const PortalAsistenciaScreen({super.key});

  static const _present = {
    1,
    2,
    3,
    7,
    8,
    9,
    10,
    13,
    14,
    15,
    16,
    17,
    20,
    22,
    23,
    24,
    28,
    29,
  };
  static const _absent = {6};

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    final content = isDesktop ? _DesktopAsistencia() : _MobileAsistencia();
    return PortalShell(currentRoute: '/portal/asistencia', child: content);
  }
}

class _MobileAsistencia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PortalMobileAppBar(),
      backgroundColor: SigmaColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asistencia — Abril 2026',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: SigmaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: AttendanceCalendar(
                year: 2026,
                month: 4,
                presentDays: PortalAsistenciaScreen._present,
                absentDays: PortalAsistenciaScreen._absent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopAsistencia extends StatefulWidget {
  @override
  State<_DesktopAsistencia> createState() => _DesktopAsistenciaState();
}

class _DesktopAsistenciaState extends State<_DesktopAsistencia> {


  final GlobalKey _widgetKey = GlobalKey();

  late CalendarCarousel<Event> calendarCarousel;
  DateTime _currentDate = DateTime(2019, 2, 3);
  DateTime _currentDate2 = DateTime(2019, 2, 3);
  String _currentMonth = DateFormat.yMMM().format(DateTime(2019, 2, 3));
  DateTime _targetDateTime = DateTime(2019, 2, 3);
  double ?wWidth, wHeight;

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
      final Size? size = renderBox?.size;
      wHeight = size?.height;
      wWidth = size?.width;
      print("Widget size: ${size?.width} x ${size?.height}");
    });

    super.initState();

    calendarCarousel = CalendarCarousel<Event>(
      onDayPressed: (date, events) {
        setState(() => _currentDate = date);
        for (var event in events) {
          debugPrint(event.title);
        }
      },
      weekendTextStyle: TextStyle(color: Colors.red),
      thisMonthDayBorderColor: Colors.grey,
      //          weekDays: null, /// for pass null when you do not want to render weekDays
      //headerText: 'Custom Header',
      weekFormat: true,
      //markedDatesMap: _markedDateMap,
      //height: 200,
      selectedDateTime: _currentDate2,
      showIconBehindDayText: true,
      //          daysHaveCircularBorder: false, /// null for not rendering any border, true for circular border, false for rectangular border
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      selectedDayTextStyle: TextStyle(color: Colors.yellow),
      todayTextStyle: TextStyle(color: Colors.blue),
      markedDateIconBuilder: (event) {
        return event.icon ?? Icon(Icons.help_outline);
      },
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.green,
      markedDateMoreShowTotal:
          true, // null for not showing hidden events indicator
      //          markedDateIconMargin: 9,
      //          markedDateIconOffset: 3,
    );

    /// Example Calendar Carousel without header and custom prev & next button
    final calendarCarouselNoHeader = CalendarCarousel<Event>(
      todayBorderColor: Colors.green,
      onDayPressed: (date, events) {
        setState(() => _currentDate2 = date);
        for (var event in events) {
          debugPrint(event.title);
        }
      },
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      weekendTextStyle: TextStyle(color: Colors.red),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      //      firstDayOfWeek: 4,
      //markedDatesMap: _markedDateMap,
      height: 420,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomShapeBorder: CircleBorder(
        side: BorderSide(color: Colors.yellow),
      ),
      markedDateCustomTextStyle: TextStyle(fontSize: 18, color: Colors.blue),
      showHeader: false,
      todayTextStyle: TextStyle(color: Colors.blue),
      // markedDateShowIcon: true,
      // markedDateIconMaxShown: 2,
      // markedDateIconBuilder: (event) {
      //   return event.icon;
      // },
      // markedDateMoreShowTotal:
      //     true,
      todayButtonColor: Colors.yellow,
      selectedDayTextStyle: TextStyle(color: Colors.yellow),
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(fontSize: 16, color: Colors.pinkAccent),
      inactiveDaysTextStyle: TextStyle(color: Colors.tealAccent, fontSize: 16),
      onCalendarChanged: (DateTime date) {
        setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        debugPrint('long pressed date $date');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _widgetKey,
      width: wWidth,
      height: wHeight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abril 2026',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: SigmaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            _StatRow(),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: calendarCarousel

                  /*  Container(
                width:500,
                  height: 300,
                  child: calendarCarousel)
              AttendanceCalendar(
                year: 2026,
                month: 4,
                presentDays: PortalAsistenciaScreen._present,
                absentDays: PortalAsistenciaScreen._absent,
              ),
              */
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Días presentes',
            value: '14',
            sub: 'Este mes',
            borderColor: SigmaColors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Días ausentes',
            value: '1',
            sub: 'Justificado',
            borderColor: SigmaColors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: '% Asistencia',
            value: '96%',
            sub: 'Acumulado',
            borderColor: SigmaColors.teal,
          ),
        ),
      ],
    );
  }
}
