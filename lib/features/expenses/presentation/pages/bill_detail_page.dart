import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/injection.dart';
import 'package:intl/intl.dart';

class BillDetailPage extends ConsumerStatefulWidget {
  final String billId;

  const BillDetailPage({super.key, required this.billId});

  @override
  ConsumerState<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends ConsumerState<BillDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(billDetailViewModelProvider.notifier)
          .getBillDetail(widget.billId);
      ref
          .read(billPaymentsViewModelProvider.notifier)
          .getBillPayments(widget.billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final billState = ref.watch(billDetailViewModelProvider);
    final paymentsState = ref.watch(billPaymentsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: billState.when(
          data: (bill) => Text(
            bill.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () =>
              const Text('Loading...', style: TextStyle(color: Colors.black)),
          error: (error, stack) =>
              const Text('Error', style: TextStyle(color: Colors.red)),
        ),
        actions: [
          IconButton(
            onPressed: () => _showBillMenu(context),
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: billState.when(
        data: (bill) => _buildBillContent(bill, paymentsState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Không thể tải hóa đơn',
                style: TextStyle(color: Colors.red[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(billDetailViewModelProvider.notifier)
                    .getBillDetail(widget.billId),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: billState.whenOrNull(
        data: (bill) => FloatingActionButton(
          onPressed: () => _showAddPaymentDialog(context, bill),
          backgroundColor: const Color(0xFF87CEEB),
          child: const Icon(Icons.payment, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBillContent(Bill bill, AsyncValue<List<Payment>> paymentsState) {
    final formatter = NumberFormat('#,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill Info Card
          _buildBillInfoCard(bill, formatter),
          const SizedBox(height: 16),

          // Participants Card
          _buildParticipantsCard(bill, formatter),
          const SizedBox(height: 16),

          // Payments Section
          _buildPaymentsSection(paymentsState, formatter),
        ],
      ),
    );
  }

  Widget _buildBillInfoCard(Bill bill, NumberFormat formatter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bill.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(bill.status),
                    color: _getStatusColor(bill.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bill.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bill.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(bill.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Tổng tiền',
                    '${formatter.format(bill.amount)} ${bill.currency}',
                  ),
                ),
                Expanded(child: _buildInfoItem('Danh mục', bill.category)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Ngày',
                    DateFormat('dd/MM/yyyy').format(bill.date),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Phương thức chia',
                    bill.splitMethod == 'equal' ? 'Chia đều' : 'Theo phần trăm',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildParticipantsCard(Bill bill, NumberFormat formatter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thành viên tham gia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...bill.participants.map(
              (participant) => _buildParticipantItem(participant, formatter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantItem(
    BillParticipant participant,
    NumberFormat formatter,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF87CEEB),
            child: Text(
              participant.userId.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${participant.userId.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${participant.share.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${formatter.format(participant.amountOwed)} VND',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF87CEEB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection(
    AsyncValue<List<Payment>> paymentsState,
    NumberFormat formatter,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ref
                      .read(billPaymentsViewModelProvider.notifier)
                      .refreshPayments(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            paymentsState.when(
              data: (payments) => payments.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Chưa có thanh toán nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: payments
                          .map(
                            (payment) => _buildPaymentItem(payment, formatter),
                          )
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Lỗi khi tải thanh toán: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(Payment payment, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(_getPaymentMethodIcon(payment.method), color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatter.format(payment.amount)} VND',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Từ: ${payment.paidBy.substring(0, 8)} → ${payment.paidTo.substring(0, 8)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (payment.notes.isNotEmpty)
                  Text(
                    payment.notes,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(payment.date),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                _getPaymentMethodText(payment.method),
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partially_paid':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'partially_paid':
        return Icons.schedule;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Đã thanh toán';
      case 'partially_paid':
        return 'Thanh toán một phần';
      default:
        return 'Chưa thanh toán';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Chuyển khoản';
      case 'cash':
        return 'Tiền mặt';
      default:
        return 'Khác';
    }
  }

  void _showBillMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa hóa đơn'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit bill page
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ hóa đơn'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Xóa hóa đơn',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete functionality
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddPaymentDialog(BuildContext context, Bill bill) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedMethod = 'bank_transfer';
    String selectedPaidBy = bill.participants.first.userId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm thanh toán'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedPaidBy,
                    decoration: const InputDecoration(
                      labelText: 'Người thanh toán',
                      border: OutlineInputBorder(),
                    ),
                    items: bill.participants.map((participant) {
                      return DropdownMenuItem(
                        value: participant.userId,
                        child: Text(
                          'User ${participant.userId.substring(0, 8)}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => selectedPaidBy = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền',
                      border: OutlineInputBorder(),
                      suffixText: 'VND',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Vui lòng nhập số tiền';
                      if (double.tryParse(value!) == null)
                        return 'Số tiền không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Phương thức thanh toán',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Chuyển khoản'),
                      ),
                      DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                      DropdownMenuItem(value: 'other', child: Text('Khác')),
                    ],
                    onChanged: (value) => selectedMethod = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (tùy chọn)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final request = CreatePaymentRequest(
                    amount: double.parse(amountController.text),
                    paidBy: selectedPaidBy,
                    paidTo: bill.paidBy,
                    date: DateTime.now(),
                    method: selectedMethod,
                    notes: notesController.text,
                  );

                  ref
                      .read(billDetailViewModelProvider.notifier)
                      .addPayment(request);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
              ),
              child: const Text(
                'Thêm thanh toán',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
