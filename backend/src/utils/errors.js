function isCastError(error) {
  return error?.name === 'CastError';
}

module.exports = { isCastError };
