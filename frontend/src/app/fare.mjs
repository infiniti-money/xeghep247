export function estimateDemoFare(unitPrice, quantity, roundTrip = false) {
  return unitPrice * quantity * (roundTrip ? 2 : 1);
}
