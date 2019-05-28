import json
import sys
import math


def num_to_char(num):
    s = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!?"
    first_char = "0"
    if num >= 32:
        first_char = s[int(num / 32)]
        num = num % 32
    return first_char + s[num]


def num_to_one_char(num):
    s = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!?"
    return s[num]


def get_chain_output(chain_length):
    chain_char = "w"
    if chain_length >= 32:
        chain_char = "x"
        chain_length -= 32
    if chain_length >= 32:
        chain_char = "y"
        chain_length -= 32
    if chain_length >= 32:
        chain_char = "z"
        chain_length -= 32
    return chain_char + num_to_one_char(chain_length)


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

        entity_list = []

        try:
            entities = data["layers"][1]["objects"]
            for e in entities:
                object_id = e["properties"]["object_id"]
                hard_mode_only = e["properties"]["hard_mode_only"]
                x = math.floor(e["x"] / 8)
                y = math.floor(e["y"] / 8)
                tile_pos = x + y * width

                add_number = 256
                if hard_mode_only:
                    add_number = 512

                new_tiles[tile_pos] += add_number

                entity_list.append((object_id, tile_pos))
        except IndexError:
            print("Index error.")
            pass

        entity_list = sorted(entity_list, key=lambda x: x[1])

        for e in entity_list:
            out_str += num_to_one_char(e[0])

        out_str += "|"

        prev_tile = -1
        chain_length = 0
        for i in range(0, len(new_tiles)):
            this_tile = new_tiles[i]
            if this_tile == prev_tile and chain_length < 127:
                chain_length += 1
            else:
                if chain_length > 0:
                    out_str += get_chain_output(chain_length)
                    chain_length = 0
                out_str += num_to_char(this_tile)
                prev_tile = this_tile

        if chain_length > 0:
            out_str += get_chain_output(chain_length)
        print(out_str)
