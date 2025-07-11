import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/presentation/view_models/bill_detail_view_model.dart';
import 'package:fairsplit/injection.dart' as di;
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
      if (mounted) {
        try {
          ref
              .read(di.billDetailViewModelProvider.notifier)
              .getBillDetail(widget.billId);
        } catch (e) {
          print('Error initializing bill detail: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billState = ref.watch(di.billDetailViewModelProvider);

    // Show success/error messages
    ref.listen<BillDetailState>(di.billDetailViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;

      try {
        if (next.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          ref.read(di.billDetailViewModelProvider.notifier).clearMessages();
        }
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
          );
          ref.read(di.billDetailViewModelProvider.notifier).clearMessages();
        }
      } catch (e) {
        print('Error showing message: $e');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: billState.bill != null
            ? Text(
                billState.bill!.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const Text('Loading...', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () => _showBillMenu(context),
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: billState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : billState.error != null
          ? Center(
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
                        .read(di.billDetailViewModelProvider.notifier)
                        .getBillDetail(widget.billId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : billState.bill != null
          ? _buildBillContent(billState.bill!)
          : const Center(child: Text('Không có dữ liệu')),
      floatingActionButton: billState.bill != null
          ? FloatingActionButton(
              onPressed: () => _showAddPaymentDialog(context, billState.bill!),
              backgroundColor: const Color(0xFF87CEEB),
              child: const Icon(Icons.payment, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBillContent(Bill bill) {
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

          // Payments Section - Use payments from bill object
          _buildPaymentsSection(bill.payments, formatter),
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
            backgroundImage: participant.avatarUrl != null
                ? NetworkImage(participant.avatarUrl!)
                : null,
            backgroundColor: const Color(0xFF87CEEB),
            child: participant.avatarUrl == null
                ? Text(
                    participant.username?.substring(0, 1).toUpperCase() ??
                        participant.userId.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.username ??
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

  Widget _buildPaymentsSection(List<Payment> payments, NumberFormat formatter) {
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
                      .read(di.billDetailViewModelProvider.notifier)
                      .getBillDetail(widget.billId),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            payments.isEmpty
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
                        .map((payment) => _buildPaymentItem(payment, formatter))
                        .toList(),
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditPaymentDialog(payment);
              } else if (value == 'delete') {
                _showDeletePaymentDialog(payment);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Chỉnh sửa'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Xóa', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
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
    final billState = ref.read(di.billDetailViewModelProvider);
    final bill = billState.bill;

    if (bill == null) return;

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
                _showEditBillDialog(context, bill);
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
                _showDeleteBillDialog(context, bill);
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
                          participant.username ??
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
                      .read(di.billDetailViewModelProvider.notifier)
                      .addPayment(widget.billId, request);
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

  void _showEditPaymentDialog(Payment payment) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: payment.amount.toString(),
    );
    final notesController = TextEditingController(text: payment.notes);
    String selectedMethod = payment.method;
    String selectedPaidBy = payment.paidBy;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final billState = ref.watch(di.billDetailViewModelProvider);

            return AlertDialog(
              title: const Text('Chỉnh sửa thanh toán'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền',
                          border: OutlineInputBorder(),
                          suffixText: 'VND',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập số tiền';
                          if (double.tryParse(value) == null)
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
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text('Tiền mặt'),
                          ),
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
                  onPressed: billState.isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            final request = CreatePaymentRequest(
                              amount: double.parse(amountController.text),
                              paidBy: selectedPaidBy,
                              paidTo: payment.paidTo,
                              date: payment.date,
                              method: selectedMethod,
                              notes: notesController.text,
                            );

                            Navigator.pop(context);
                            if (payment.id.isNotEmpty) {
                              ref
                                  .read(di.billDetailViewModelProvider.notifier)
                                  .updatePayment(
                                    widget.billId,
                                    payment.id,
                                    request,
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Không thể cập nhật thanh toán: ID không hợp lệ',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                  ),
                  child: billState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Cập nhật',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeletePaymentDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final billState = ref.watch(di.billDetailViewModelProvider);

            return AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: Text(
                'Bạn có chắc chắn muốn xóa thanh toán ${NumberFormat('#,##0', 'vi').format(payment.amount)} VND?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: billState.isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                          if (payment.id.isNotEmpty) {
                            ref
                                .read(di.billDetailViewModelProvider.notifier)
                                .deletePayment(widget.billId, payment.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Không thể xóa thanh toán: ID không hợp lệ',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: billState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBillDialog(BuildContext context, Bill bill) {
    // For now, show a simple dialog since we don't have group members data
    // In a real app, you would need to get group members from the group
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hóa đơn'),
        content: const Text(
          'Tính năng chỉnh sửa hóa đơn sẽ được cập nhật sau.\n\nBạn có thể sử dụng form dialog với danh sách thành viên từ group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBillDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa hóa đơn'),
        content: Text(
          'Bạn có chắc chắn muốn xóa hóa đơn "${bill.title}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(di.billDetailViewModelProvider.notifier)
                  .deleteBill(bill.id);
              // Navigate back after deletion
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
