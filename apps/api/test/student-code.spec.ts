const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

describe('student access code alphabet', () => {
  it('excludes visually confusing characters', () => {
    expect(alphabet).not.toMatch(/[01ILO]/);
    expect(new Set(alphabet).size).toBe(alphabet.length);
  });
});
