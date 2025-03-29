# frozen_string_literal: true

require 'json'
require 'date'

def load_busy_slots(file_path)
  raw_file = File.read(file_path)
  JSON.parse(raw_file, symbolize_names: true).map do |slot|
    {
      start: DateTime.parse(slot[:start]),
      end: DateTime.parse(slot[:end])
    }
  end
end

# Generate every slot available in a workday
def generate_possible_slots(date)
  workday_start = DateTime.parse("#{date}T09:00:00")
  workday_end = DateTime.parse("#{date}T18:00:00")

  # We assume that 1 slot = 60 minutes
  minutes_duration = 60
  slots = []

  # DateTime math is in days so we need to convert minutes into fraction of day (1 day = 1440 minutes)
  while workday_start + minutes_duration / 1440.0 <= workday_end
    slots << {
      start: workday_start,
      end: workday_start + minutes_duration / 1440.0
    }
    workday_start += minutes_duration / 1440.0
  end

  slots
end

def slot_available?(slot, busy_slots)
  busy_slots.none? do |busy|
    slot[:start] < busy[:end] && slot[:end] > busy[:start]
  end
end

def find_available_slots(file1, file2)
  result = {}

  sandra_slots = load_busy_slots(file1)
  andy_slots = load_busy_slots(file2)

  all_slots = sandra_slots + andy_slots
  # Get the earliest date from the busy slots
  first_date = all_slots.map { |slot| slot[:start].to_date }.min

  # Get the Monday of that week
  days_since_monday = (first_date.wday - 1) % 7
  monday = first_date - days_since_monday

  # Build the week from Monday to Friday
  week_days = (0..4).map { |i| monday + i }

  week_days.each do |date|
    possible_slots = generate_possible_slots(date)

    available_slots = possible_slots.select do |slot|
      slot_available?(slot, sandra_slots) && slot_available?(slot, andy_slots)
    end

    result[date] = available_slots
  end

  result
end

if __FILE__ == $PROGRAM_NAME
  file_sandra = 'data/input_sandra.json'
  file_andy = 'data/input_andy.json'

  available_slots = find_available_slots(file_sandra, file_andy)

  available_slots.each do |date, slots|
    formatted_date = date.strftime('%d-%m-%Y')
    puts "Disponibilités pour le #{formatted_date} :"
    if slots.empty?
      puts 'Aucun créneau disponible'
    else
      slots.each do |slot|
        start_time = slot[:start].strftime('%H:%M')
        end_time   = slot[:end].strftime('%H:%M')
        puts "#{start_time} - #{end_time}"
      end
    end
    puts "\n"
  end
end
