import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/common/breakpoints.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/cart/domain/model/cart_item.dart';
import 'package:shop/cart/presentation/bloc/cart_cubit.dart';
import 'package:shop/cart/presentation/ui/cart_item_tile.dart';
import 'package:shop/common/ui/app_shell.dart';
import 'package:shop/order/presentation/bloc/order_cubit.dart';
import 'package:shop/routes.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, orderState) {
        if (orderState.isSuccess) {
          context.read<CartCubit>().clear();
          context.go(kHomeRoute);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Заказ отправлен! Мы свяжемся с вами.'),
              backgroundColor: Color(0xFF7C3AED),
            ),
          );
        }
        if (orderState.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка отправки: ${orderState.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return ListView(
            children: [
              ContentBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go(kHomeRoute),
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              'Главная',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.chevron_right,
                              size: 16, color: Color(0xFF9CA3AF)),
                        ),
                        GestureDetector(
                          onTap: () => context.push(kProductBasketRoute),
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              'Корзина',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.chevron_right,
                              size: 16, color: Color(0xFF9CA3AF)),
                        ),
                        const Text(
                          'Оформление заказа',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    const Gap(16),
                    const Text(
                      'Оформление заказа',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Gap(32),
                    if (context.isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OrderSummary(items: state.items),
                          const Gap(24),
                          _OrderForm(
                            formKey: _formKey,
                            firstNameCtrl: _firstNameCtrl,
                            lastNameCtrl: _lastNameCtrl,
                            phoneCtrl: _phoneCtrl,
                            addressCtrl: _addressCtrl,
                            firstNameFocus: _firstNameFocus,
                            lastNameFocus: _lastNameFocus,
                            phoneFocus: _phoneFocus,
                            addressFocus: _addressFocus,
                            cartItems: state.items,
                          ),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _OrderForm(
                              formKey: _formKey,
                              firstNameCtrl: _firstNameCtrl,
                              lastNameCtrl: _lastNameCtrl,
                              phoneCtrl: _phoneCtrl,
                              addressCtrl: _addressCtrl,
                              firstNameFocus: _firstNameFocus,
                              lastNameFocus: _lastNameFocus,
                              phoneFocus: _phoneFocus,
                              addressFocus: _addressFocus,
                              cartItems: state.items,
                            ),
                          ),
                          const Gap(40),
                          Expanded(
                            flex: 2,
                            child: _OrderSummary(items: state.items),
                          ),
                        ],
                      ),
                    const Gap(48),
                  ],
                ),
              ),
            ],
        );
      },
    ),
    );
  }
}

// =============================================================================

class _OrderForm extends StatelessWidget {
  const _OrderForm({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.firstNameFocus,
    required this.lastNameFocus,
    required this.phoneFocus,
    required this.addressFocus,
    required this.cartItems,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final FocusNode firstNameFocus;
  final FocusNode lastNameFocus;
  final FocusNode phoneFocus;
  final FocusNode addressFocus;
  final List<CartItem> cartItems;

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Контактные данные',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Gap(20),
                if (context.isMobile)
                  Column(
                    children: [
                      _Field(
                        controller: firstNameCtrl,
                        focusNode: firstNameFocus,
                        label: 'Имя',
                        hint: 'Введите имя',
                        validator: _required,
                      ),
                      const Gap(12),
                      _Field(
                        controller: lastNameCtrl,
                        focusNode: lastNameFocus,
                        label: 'Фамилия',
                        hint: 'Введите фамилию',
                        validator: _required,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: firstNameCtrl,
                          focusNode: firstNameFocus,
                          label: 'Имя',
                          hint: 'Введите имя',
                          validator: _required,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _Field(
                          controller: lastNameCtrl,
                          focusNode: lastNameFocus,
                          label: 'Фамилия',
                          hint: 'Введите фамилию',
                          validator: _required,
                        ),
                      ),
                    ],
                  ),
                const Gap(16),
                _Field(
                  controller: phoneCtrl,
                  focusNode: phoneFocus,
                  label: 'Телефон',
                  hint: '+7 (___) ___-__-__',
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                const Gap(16),
                _Field(
                  controller: addressCtrl,
                  focusNode: addressFocus,
                  label: 'Адрес доставки',
                  hint: 'Город, улица, дом, квартира',
                  maxLines: 3,
                  validator: _required,
                ),
              ],
            ),
          ),
          const Gap(16),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) => SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: orderState.isLoading
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          context.read<OrderCubit>().submit(
                                firstName: firstNameCtrl.text.trim(),
                                lastName: lastNameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                items: cartItems,
                              );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: orderState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Оформить',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (_) => focusNode?.unfocus(),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// =============================================================================

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    final totalCount = items.fold(0, (s, i) => s + i.quantity);
    final totalPrice = items.fold(0.0, (s, i) => s + i.product.price * i.quantity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Состав заказа',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const Gap(16),
          ...items.map((item) => _SummaryItem(item: item)),
          const Gap(8),
          const Divider(color: Color(0xFFE5E7EB)),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalCount шт.',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (totalPrice > 0)
                Text(
                  '${totalPrice.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF7C3AED),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final linePrice = item.product.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CartItemTile(
        item: item,
        size: CartItemTileSize.small,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (linePrice > 0)
              Text(
                '${linePrice.toStringAsFixed(0)} ₽',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              '× ${item.quantity} шт.',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
