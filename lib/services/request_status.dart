enum RequestStatus {
  pending('⏳'),
  sent('✉️'),
  completed('✅'),
  failed('❌'),
  cancelled('🚫');

  final String symbol;
  const RequestStatus(this.symbol);
}
