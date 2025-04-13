from mido import Message, MidiFile, MidiTrack
import random

# Tổng thời gian mong muốn: 5 phút = 300 giây
# Với tempo mặc định: 500000 us/beat = 0.5s/beat
# 480 ticks per beat (default)
# => 1 giây = 960 ticks
# => 5 phút = 300 giây = 288000 ticks

total_ticks = 288000
ticks_per_note = 600 
num_notes = total_ticks // ticks_per_note  # => 480 nốt

mid = MidiFile()
track = MidiTrack()
mid.tracks.append(track)

track.append(Message('program_change', program=0, time=0))
for i in range(num_notes):
    note = random.choice([60, 62, 65, 67, 69, 72])
    velocity = random.randint(60, 90)
    track.append(Message('note_on', note=note, velocity=velocity, time=200))
    track.append(Message('note_off', note=note, velocity=0, time=400))

mid.save('midi_output.mid')