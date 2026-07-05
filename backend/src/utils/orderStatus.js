const VALID_STATUSES = ['PENDING', 'CONFIRMED', 'BAKING', 'READY', 'DELIVERED', 'CANCELLED'];

const STATUS_TRANSITIONS = {
  PENDING: ['CONFIRMED', 'CANCELLED'],
  CONFIRMED: ['BAKING', 'CANCELLED'],
  BAKING: ['READY', 'CANCELLED'],
  READY: ['DELIVERED'],
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
