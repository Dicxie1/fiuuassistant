import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/emergency_contact/domain/entities/emergency_contact.dart';

class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact? contact;
  final VoidCallback onEdit;
  final VoidCallback onCall;

  const EmergencyContactCard({
    super.key,
    this.contact,
    required this.onEdit,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: contact != null
              ? const Color(0xFF58A6A6).withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: contact != null ? onCall : onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: contact != null
                    ? const Color(0xFF58A6A6).withOpacity(0.2)
                    : Colors.grey[200],
                child: Icon(
                  contact != null ? Icons.person : Icons.add,
                  color: contact != null ? const Color(0xFF58A6A6) : Colors.grey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact?.name ?? 'Agregar Contacto de Emergencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: contact != null
                            ? const Color(0xFF2C3E50)
                            : Colors.grey[600],
                      ),
                    ),
                    if (contact != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${contact!.relationship} • ${contact!.phone}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        'Configura quien contactar en caso de emergencia',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (contact != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF58A6A6),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
