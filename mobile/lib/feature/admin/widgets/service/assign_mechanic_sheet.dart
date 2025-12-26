import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AssignMechanicSheet extends StatefulWidget {
  const AssignMechanicSheet({super.key});

  @override
  State<AssignMechanicSheet> createState() => _AssignMechanicSheetState();
}

class _AssignMechanicSheetState extends State<AssignMechanicSheet> {
  // Dummy data for mechanics
  final List<Map<String, dynamic>> mechanics = [
    {
      'name': 'Budi Santoso',
      'avatar': 'https://i.pravatar.cc/150?u=budi',
      'status': 'available', // available, busy
      'tasks': 0,
    },
    {
      'name': 'Ahmad Dhani',
      'avatar': 'https://i.pravatar.cc/150?u=ahmad',
      'status': 'busy',
      'tasks': 2,
    },
    {
      'name': 'Joko Anwar',
      'avatar': 'https://i.pravatar.cc/150?u=joko',
      'status': 'available',
      'tasks': 0,
    },
    {
      'name': 'Reza Rahadian',
      'avatar': 'https://i.pravatar.cc/150?u=reza',
      'status': 'busy',
      'tasks': 1,
    },
    {
      'name': 'Dimas Anggara',
      'avatar': 'https://i.pravatar.cc/150?u=dimas',
      'status': 'available',
      'tasks': 0,
    },
  ];

  int _selectedIndex = 0; // Default first selected

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32), // More rounded like design
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pilih Mekanik",
                  style: AppTextStyles.heading4().copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey), // Rounded icon
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(40, 40),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // List
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: mechanics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final mechanic = mechanics[index];
                final isSelected = _selectedIndex == index;
                final isBusy = mechanic['status'] == 'busy';

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500), // Slower, "lazy" duration
                    curve: Curves.fastOutSlowIn, // Smooth curve
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryRed.withOpacity(0.04) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryRed : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected 
                          ? [] 
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        // Avatar with lazy scale
                        AnimatedScale(
                          scale: isSelected ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutBack,
                          child: Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(mechanic['avatar']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isBusy ? Colors.red : Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mechanic['name'],
                                style: AppTextStyles.bodyMedium(
                                  color: AppColors.textPrimary,
                                ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isBusy ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      isBusy ? "Sibuk: ${mechanic['tasks']} Tugas" : "Tersedia",
                                      style: AppTextStyles.caption().copyWith(
                                        color: isBusy ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Checkmark with pop in effect
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Button
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, mechanics[_selectedIndex]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryRed.withOpacity(0.4),
                ),
                child: Text(
                  "Konfirmasi",
                  style: AppTextStyles.heading5(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
