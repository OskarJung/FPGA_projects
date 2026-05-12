import os
script_dir = os.path.dirname(os.path.abspath(__file__))

in_path = os.path.join(script_dir, "../data/in_data.bin")
out_path = os.path.join(script_dir, "../data/out_data.bin")

with open(in_path, "r", encoding="utf-8") as file:
    enter_txt = file.read().strip() 

print(f"Wczytano napis do wyslania: '{enter_txt}'")

expected_bits = ""

for litera in enter_txt:
    ascii_val = ord(litera)
    bin_str = format(ascii_val, '08b')
    lsb_first = bin_str[::-1]
    frame = "0" + "1" + lsb_first + "00"
    expected_bits += frame

print(f"Generate a math model with {len(expected_bits)} bits.")


with open(out_path, "r") as file:
    vivado_bity = file.read().strip()

print(f"Read results from Vivado simulation, length: {len(vivado_bity)} bits.")

if expected_bits in vivado_bity:
    print("\n[ RESULT: SUCCESS! ]")
else:
    print("\n[ RESULT: ERROR! ]")
    
print("Expected start: ", expected_bits[:60])
print("Vivado start:   ", vivado_bity[:60])