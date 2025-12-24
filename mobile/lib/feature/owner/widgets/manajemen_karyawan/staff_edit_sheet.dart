import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';

class StaffEditResult {
  final String? name;
  final String? username;
  final String? email;
  final String? role;
  final String? specialist;
  final String? jobdesk;
  StaffEditResult({this.name, this.username, this.email, this.role, this.specialist, this.jobdesk});
}

class StaffEditSheet extends StatefulWidget {
  const StaffEditSheet({super.key, required this.employment});
  final Employment employment;

  @override
  State<StaffEditSheet> createState() => _StaffEditSheetState();
}

class _StaffEditSheetState extends State<StaffEditSheet> {
  static const _danger = Color(0xFFDC2626);

  late final TextEditingController _name =
      TextEditingController(text: widget.employment.name);
  late final TextEditingController _username =
      TextEditingController(text: widget.employment.user?.username ?? '');
  late final TextEditingController _mail =
      TextEditingController(text: widget.employment.email);
  late final TextEditingController _specialist =
      TextEditingController(text: widget.employment.specialist ?? '');
  late final TextEditingController _jobdesk =
      TextEditingController(text: widget.employment.jobdesk ?? '');
  late String _role = (widget.employment.role.isEmpty) ? 'mechanic' : widget.employment.role;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _mail.dispose();
    _specialist.dispose();
    _jobdesk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 16),
          const Text('Edit Karyawan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _danger)),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
          const SizedBox(height: 12),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(controller: _mail, decoration: const InputDecoration(labelText: 'E-Mail')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _role,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'mechanic', child: Text('Mekanik')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'mechanic'),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _specialist, decoration: const InputDecoration(labelText: 'Spesialis')),
          const SizedBox(height: 12),
          TextField(controller: _jobdesk, decoration: const InputDecoration(labelText: 'Jobdesk')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _danger,
                    side: const BorderSide(color: _danger),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _danger, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      StaffEditResult(
                        name: _name.text.trim(),
                        username: _username.text.trim(),
                        email: _mail.text.trim(),
                        role: _role,
                        specialist: _specialist.text.trim(),
                        jobdesk: _jobdesk.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
