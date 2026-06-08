import 'package:flutter/material.dart';
import 'package:setgo/src/data/constants/color_constants.dart';
import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:setgo/src/data/models/business_info.dart';


class BranchCard extends StatelessWidget {
  final BusinessBranch branch;
  final bool isEditMode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BranchCard({
    super.key,
    required this.branch,
    this.isEditMode = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_outlined,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        branch.name ?? 'Branch',
                        style: kBodyTitleM.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (branch.isPrimary == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0XFFDFEAFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Primary',
                    style: kSmallTitleL.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: branch.isActive == true
                      ? const Color(0xFFDEF7EC)
                      : const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  branch.isActive == true ? 'Active' : 'Inactive',
                  style: kSmallTitleL.copyWith(
                    color: branch.isActive == true
                        ? const Color(0xFF03543F)
                        : const Color(0xFF9B1C1C),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (branch.address?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.address!,
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (branch.phone?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.phone!,
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isEditMode) ...[
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              color: Color(0xFFF3F4F6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: kSmallTitleM.copyWith(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 24),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: kSmallTitleM.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
