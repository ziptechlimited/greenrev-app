import 'package:flutter/material.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';

class CompareScreen extends StatelessWidget {
  final List<ProductModel> vehicles;

  const CompareScreen({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VEHICLE COMPARISON'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Table(
            border: TableBorder.all(
              color: Colors.white12,
              width: 1,
              borderRadius: BorderRadius.circular(16),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              // 1. Vehicle Images Row
              TableRow(
                children: [
                  const TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('IMAGE', style: TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                  ...vehicles.map((v) => TableCell(
                        child: Container(
                          height: 80,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(image: safeImageProvider(v.image), fit: BoxFit.cover),
                          ),
                        ),
                      )),
                  // Fill empty columns if less than 3 vehicles
                  ...List.generate(3 - vehicles.length, (_) => const TableCell(child: SizedBox())),
                ],
              ),
              // 2. Name Row
              _buildTableRow('NAME', vehicles.map((v) => v.name).toList()),
              // 3. Price Row
              _buildTableRow('PRICE', vehicles.map((v) => v.price).toList()),
              // 4. Year Row
              _buildTableRow('YEAR', vehicles.map((v) => v.year?.toString() ?? 'N/A').toList()),
              // 5. HP Row
              _buildTableRow('POWER', vehicles.map((v) => v.specs?.horsepower != null ? '${v.specs!.horsepower} HP' : 'N/A').toList()),
              // 6. Acceleration Row
              _buildTableRow('0 - 100 KM/H', vehicles.map((v) => v.specs?.acceleration != null ? '${v.specs!.acceleration}s' : 'N/A').toList()),
              // 7. Torque Row
              _buildTableRow('TORQUE', vehicles.map((v) => v.specs?.torque ?? 'N/A').toList()),
              // 8. Transmission Row
              _buildTableRow('DRIVE RATIO', vehicles.map((v) => v.specs?.transmission ?? 'N/A').toList()),
              // 9. Top Speed Row
              _buildTableRow('LIMIT', vehicles.map((v) => v.specs?.topSpeed ?? 'N/A').toList()),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, List<String> values) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Text(label, style: const TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        ),
        ...values.map((val) => TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: Text(
                  val,
                  style: TextStyle(
                    color: label == 'PRICE' ? AppTheme.accent : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
        ...List.generate(3 - values.length, (_) => const TableCell(child: SizedBox())),
      ],
    );
  }
}
