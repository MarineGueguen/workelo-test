require 'spec_helper'
require_relative '../lib/calendar'

RSpec.describe 'Calendar methods with JSON fixtures' do
  let(:fixtures_path) { File.expand_path('fixtures', __dir__) }

  let(:sandra_file) { File.join(fixtures_path, 'sandra_fixture.json') }
  let(:andy_file)   { File.join(fixtures_path, 'andy_fixture.json') }

  describe '#load_busy_slots' do
    it 'loads busy slots as DateTime hashes' do
      slots = load_busy_slots(sandra_file)
      expect(slots).to be_an(Array)
      expect(slots.length).to eq(3)
      expect(slots.first).to include(:start, :end)
    end
  end

  describe '#generate_possible_slots' do
    it 'generates slots from 9:00 to 18:00' do
      date = Date.parse('2022-08-04')
      slots = generate_possible_slots(date)
      expect(slots.size).to eq(9)
      expect(slots.first[:start].strftime('%H:%M')).to eq('09:00')
      expect(slots.last[:end].strftime('%H:%M')).to eq('18:00')
    end
  end

  describe '#slot_available?' do
    let(:busy_slots) do
      [
        { start: DateTime.parse('2022-08-04T10:00:00'), end: DateTime.parse('2022-08-04T11:00:00') }
      ]
    end

    it 'returns false if the slot overlaps a busy time' do
      slot = { start: DateTime.parse('2022-08-04T10:30:00'), end: DateTime.parse('2022-08-04T11:30:00') }
      expect(slot_available?(slot, busy_slots)).to be false
    end

    it 'returns true if the slot does not overlap any busy time' do
      slot = { start: DateTime.parse('2022-08-04T11:00:00'), end: DateTime.parse('2022-08-04T12:00:00') }
      expect(slot_available?(slot, busy_slots)).to be true
    end
  end

  describe '#find_available_slots' do
    it 'returns a hash with available slots for the working week' do
      result = find_available_slots(sandra_file, andy_file)
      expect(result).to be_a(Hash)
      expect(result.keys.size).to eq(5)
    end

    it 'returns the exact expected available time slots for Thursday' do
      result = find_available_slots(sandra_file, andy_file)
      date = Date.parse('2022-08-04')
      slots = result[date]

      expect(slots.size).to eq(3)

      times = slots.map do |slot|
        [slot[:start].strftime('%H:%M'), slot[:end].strftime('%H:%M')]
      end

      expect(times).to eq([
          ['12:00', '13:00'],
          ['16:00', '17:00'],
          ['17:00', '18:00']
      ])
    end

    it 'returns 9 slots if no one is busy' do
      result = find_available_slots(sandra_file, andy_file)
      date = Date.parse('2022-08-05')
      slots = result[date]
      expect(slots.size).to eq(9)
    end
  end
end
