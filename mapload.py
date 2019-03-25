import json
import sys
import math


def num_to_char(num):
    s = "0123456789abcdefghijklmnopqrstuv"
    first_char = "0"
    if num >= 32:
        first_char = s[int(num / 32)]
        num = num % 32
    return first_char + s[num]


def num_to_one_char(num):
    s = "0123456789abcdefghijklmnopqrstuv"
    return s[num]


if len(sys.argv) <= 1:
    print("Please specify file name")
else:
    parameter = sys.argv[1]
    with open(parameter) as f:
        data = json.load(f)
        old_tiles = data["layers"][0]["data"]
        new_tiles = []
        for i in old_tiles:
            num = int(i) - 65
            if num < 0:
                num = 0
            new_tiles.append(num)

        width = data["layers"][0]["width"]
        out_str = num_to_char(width)

        try:
            entities = data["layers"][1]["objects"]
            for e in entities:
                object_id = e["properties"]["object_id"]
                hard_mode_only = e["properties"]["hard_mode_only"]
                x = math.floor(e["x"]/8)
                y = math.floor(e["y"]/8)
                tile_pos = x + y * width

                add_number = 256
                if hard_mode_only:
                    add_number = 512

                new_tiles[tile_pos] += add_number

                out_str += num_to_one_char(object_id)
        except IndexError:
            print("Index error.")
            pass

        out_str += "|"

        for i in range(0, len(new_tiles)):
            out_str += num_to_char(new_tiles[i])

        print(out_str)
