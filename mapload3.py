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
    # Read the file specified
    parameter = sys.argv[1]
    with open(parameter) as f:
        # Load the data from JSON
        data = json.load(f)
        old_tiles = data["layers"][0]["data"]
        new_tiles = []
        for i in old_tiles:
            num = int(i) - 65
            if num < 0 or num > 127:
                num = 63  # Empty tile
            new_tiles.append(num)

        # Get the width and put it at the start of the output string
        width = data["layers"][0]["width"]
        out_str = num_to_char(width)

        tiles = [[]]
        x = 0
        y = 0
        for tile in new_tiles:
            tiles[y].append(tile)
            x += 1
            if x >= width:
                x = 0
                y += 1
                if y < 28:
                    tiles.append([])

        # # Load the entities in
        # entity_list = []
        # try:
        #     entities = data["layers"][1]["objects"]
        #     for e in entities:
        #         object_id = e["properties"]["object_id"]
        #         hard_mode_only = e["properties"]["hard_mode_only"]
        #         x = math.floor(e["x"] / 8)
        #         y = math.floor(e["y"] / 8)
        #         tile_pos = x + y * width
        #
        #         # add_number = 256
        #         # if hard_mode_only:
        #         #     add_number = 512
        #         #
        #         # new_tiles[tile_pos] += add_number
        #
        #         text = num_to_one_char(object_id)
        #         # Based on the hard mode option of the object, append either a semicolon (just hard) or a colon (always)
        #         if hard_mode_only:
        #             text = ";" + text
        #         else:
        #             text = ":" + text
        #
        #         entity_list.append((text, tile_pos))
        # except IndexError:
        #     print("There is no entity layer on this map.")
        #
        # running_add_value = 0
        # tile_num = 0
        # prev_tile = -1
        # chain_length = 0
        # for tile in new_tiles:
        #
        #     # Check for an entity on this tile:
        #     for e in entity_list:
        #         if e[1] == tile_num:
        #             if chain_length > 0:
        #                 out_str += "+" + num_to_one_char(chain_length)
        #             prev_tile = -1
        #             chain_length = 0
        #             out_str += e[0]
        #
        #     # Determine whether it's part of the first or second graphics bank
        #     add_value = 0
        #     if tile >= 64:
        #         add_value = 64
        #     # Find out whether the graphics bank changed since the last tile.
        #     if add_value != running_add_value:
        #         # If it changed, we use a '/' character to show this.
        #         out_str += "/"
        #         running_add_value = add_value
        #     # Add on the value within the given graphics bank.
        #     if tile == prev_tile:
        #         chain_length += 1
        #     else:
        #         if chain_length > 0:
        #             out_str += "+" + num_to_one_char(chain_length)
        #         prev_tile = tile
        #         chain_length = 0
        #         out_str += num_to_one_char(tile - add_value)
        #
        #     tile_num += 1
        #
        #     if chain_length >= 63:
        #         out_str += "+" + num_to_one_char(chain_length)
        #         prev_tile = -1
        #         chain_length = 0
        #
        # if chain_length > 0:
        #     out_str += "+" + num_to_one_char(chain_length)
        # print(out_str)
