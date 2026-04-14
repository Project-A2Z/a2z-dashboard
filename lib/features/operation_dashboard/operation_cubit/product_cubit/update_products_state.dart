import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class UpdateProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateProductInitial extends UpdateProductState {}

class UpdateProductLoading extends UpdateProductState {}

class UpdateProductSuccess extends UpdateProductState {
  final ProductModel product;

  UpdateProductSuccess(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductError extends UpdateProductState {
  final String message;

  UpdateProductError(this.message);

  @override
  List<Object?> get props => [message];
}
