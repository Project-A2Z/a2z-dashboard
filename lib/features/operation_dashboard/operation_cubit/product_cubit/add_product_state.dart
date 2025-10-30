import 'package:equatable/equatable.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';

abstract class AddProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductSuccess extends AddProductState {
  final ProductModel product;
  AddProductSuccess(this.product);
  @override
  List<Object?> get props => [product];
}

class AddProductFailure extends AddProductState {
  final String message;
  AddProductFailure(this.message);
  @override
  List<Object?> get props => [message];
}
