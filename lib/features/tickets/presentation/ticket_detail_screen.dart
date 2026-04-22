import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';

class TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late String currentStatus;
  late String currentAssignee;

  final List<String> statusOptions = ['Open', 'In Progress', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.ticket['status'];
    currentAssignee = widget.ticket['assignedTo'];
  }

  @override
  Widget build(BuildContext context) {
    List chats = widget.ticket['chats'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Tiket dari ${widget.ticket['user']}", style: const TextStyle(fontSize: 16)),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(widget.ticket['userAvatar'])),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.ticket['user'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(widget.ticket['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(widget.ticket['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Divider(),
                      
                      const Text("Tindakan Admin & Helpdesk:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          const Icon(Icons.assignment_ind, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text("Assign ke: ", style: TextStyle(color: Colors.grey)),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: currentAssignee == 'None' ? null : currentAssignee,
                                hint: const Text("Pilih Teknisi..."),
                                items: DummyData.helpdeskStaff.map((staff) => DropdownMenuItem(value: staff, child: Text(staff))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => currentAssignee = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          const Icon(Icons.rule, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text("Status: ", style: TextStyle(color: Colors.grey)),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: currentStatus,
                                items: statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => currentStatus = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Riwayat Chat (${chats.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                ...chats.map((msg) => _buildChatBubble(msg, context)).toList(),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(24)),
                      child: const TextField(
                        decoration: InputDecoration(hintText: "Tulis balasan...", border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1877F2),
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: () {}),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map msg, BuildContext context) {
    bool isMe = msg['isMe'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(widget.ticket['userAvatar'])),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF1877F2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) Text(msg['sender'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                  Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}