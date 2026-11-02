const VALID_STATUSES = [
  'PENDING',
  'CONFIRMED',
  'BAKING',
  'READY',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
];

const STATUS_TRANSITIONS = {
  PENDING: ['CONFIRMED', 'BAKING', 'CANCELLED'],
  CONFIRMED: ['BAKING', 'CANCELLED'],
  BAKING: ['READY', 'CANCELLED'],
  READY: ['OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'],
  OUT_FOR_DELIVERY: ['DELIVERED', 'CANCELLED'],
  DELIVERED: [],
  CANCELLED: [],
};

function allowedNextStatuses(current) {
  return STATUS_TRANSITIONS[current] || [];
}

function canTransition(from, to) {
  return allowedNextStatuses(from).includes(to);
}

module.exports = {
  VALID_STATUSES,
  allowedNextStatuses,
  canTransition,
};
