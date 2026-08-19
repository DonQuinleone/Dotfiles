#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

readonly PTT="${BIN_DIR}/donbox-ptt"
readonly API_KEY=AAAA-BBBB-CCCC-DDDD-EEEE-FFFF
readonly TAP_MS=0.1
readonly HOLD_MS=0.4

require_command python3

workspace

# Nothing here may reach a microphone, a speaker or a running
# client, so the suite answers in the client's place and the two
# commands that would leave the machine are stubs.
cat >"${WORKSPACE}/pw-play" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB

cat >"${WORKSPACE}/notify-send" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB

chmod +x "${WORKSPACE}/pw-play" "${WORKSPACE}/notify-send"

# The client ends every line with newline then carriage return
# rather than the other way about, which is the whole reason the
# reader strips returns wherever they land.
cat >"${WORKSPACE}/clientquery.py" <<'FAKE'
import socket
import sys

port_file, log_file, state_file = sys.argv[1:4]
MUTE = "clientupdate client_input_muted="


def muted():
    return open(state_file).read().strip()


def reply(connection, line):
    connection.sendall(line.encode() + b"\n\r")


def answer(connection, command):
    with open(log_file, "a") as handle:
        handle.write(command + "\n")
    if command == "whoami":
        reply(connection, "clid=7 cid=1")
    elif command.startswith("clientvariable"):
        reply(connection, f"clid=7 client_input_muted={muted()}")
    elif command.startswith(MUTE):
        with open(state_file, "w") as handle:
            handle.write(command.split("=")[-1])
    reply(connection, "error id=0 msg=ok")


def serve(connection):
    reply(connection, "TS3 Client")
    reply(connection, 'Use the "auth" command to authenticate.')
    rest = b""
    while True:
        chunk = connection.recv(4096)
        if not chunk:
            return
        rest += chunk
        while b"\n" in rest:
            raw, rest = rest.split(b"\n", 1)
            command = raw.decode().strip()
            if command == "quit":
                return
            if command:
                answer(connection, command)


listener = socket.socket()
listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
listener.bind(("127.0.0.1", 0))
listener.listen(4)
with open(port_file, "w") as handle:
    handle.write(f"{listener.getsockname()[1]}\n")

while True:
    connection, _ = listener.accept()
    try:
        serve(connection)
    except OSError:
        pass
    finally:
        connection.close()
FAKE

readonly PORT_FILE="${WORKSPACE}/port"
readonly LOG_FILE="${WORKSPACE}/commands"
readonly CLIENT_STATE="${WORKSPACE}/muted"

printf '1' >"${CLIENT_STATE}"
python3 "${WORKSPACE}/clientquery.py" \
    "${PORT_FILE}" "${LOG_FILE}" "${CLIENT_STATE}" &
readonly FAKE_PID=$!
trap 'kill "${FAKE_PID}" 2>/dev/null || true
      rm -rf "${WORKSPACE}"' EXIT

for _ in $(seq 50); do
    [[ -s "${PORT_FILE}" ]] && break
    sleep 0.05
done
assert "the stand-in client is listening" [ -s "${PORT_FILE}" ]

export PATH="${WORKSPACE}:${PATH}"
export XDG_STATE_HOME="${WORKSPACE}/state"
export XDG_CONFIG_HOME="${WORKSPACE}/config"
export XDG_RUNTIME_DIR="${WORKSPACE}/run"
export DONBOX_PTT_PORT
DONBOX_PTT_PORT=$(cat "${PORT_FILE}")

mkdir -p "${XDG_CONFIG_HOME}/ts3client" "${XDG_RUNTIME_DIR}"
printf '[General]\napi_key=%s\n' "${API_KEY}" \
    >"${XDG_CONFIG_HOME}/ts3client/clientquery.ini"

readonly STATE_FILE="${XDG_STATE_HOME}/donbox/ptt"

ptt() {
    "${PTT}" "$@"
}

client_muted() {
    cat "${CLIENT_STATE}"
}

assert_equal "it starts with the microphone shut" \
    "$(ptt status)" "off"

assert_equal "status leaves the client muted" "$(client_muted)" "1"

ptt press
assert_equal "a press opens the microphone" \
    "$(cat "${STATE_FILE}")" "held"
assert_equal "the client hears the press" "$(client_muted)" "0"

sleep "${TAP_MS}"
ptt release
assert_equal "letting go of a tap latches it open" \
    "$(cat "${STATE_FILE}")" "latched"
assert_equal "a latch keeps the microphone open" \
    "$(client_muted)" "0"

assert_equal "status reports the latch" "$(ptt status)" "latched"

ptt press
assert_equal "pressing again drops the latch" \
    "$(cat "${STATE_FILE}")" "off"
assert_equal "dropping the latch mutes the client" \
    "$(client_muted)" "1"

ptt release
assert_equal "the release after that changes nothing" \
    "$(cat "${STATE_FILE}")" "off"

ptt press
sleep "${HOLD_MS}"
ptt release
assert_equal "a held key closes when it comes up" \
    "$(cat "${STATE_FILE}")" "off"
assert_equal "holding leaves the client muted" \
    "$(client_muted)" "1"

# A release the compositor never delivered would otherwise strand
# the microphone open with no press able to close it.
ptt press
ptt press
assert_equal "a second press recovers a lost release" \
    "$(cat "${STATE_FILE}")" "off"
assert_equal "recovery mutes the client" "$(client_muted)" "1"

assert_equal "toggle latches without a key" "$(ptt toggle)" "latched"
assert_equal "toggle shuts it again" "$(ptt toggle)" "off"

# The client is the authority on its own microphone.
printf 'latched\n' >"${STATE_FILE}"
assert_equal "status believes a client that is muted" \
    "$(ptt status)" "off"

printf '0' >"${CLIENT_STATE}"
printf 'off\n' >"${STATE_FILE}"
assert_equal "status believes a client that is open" \
    "$(ptt status)" "latched"
printf '1' >"${CLIENT_STATE}"

assert "the client was asked, not guessed at" \
    grep -q "^clientupdate client_input_muted=0$" "${LOG_FILE}"

assert "every exchange authenticated first" \
    grep -q "^auth apikey=${API_KEY}$" "${LOG_FILE}"

assert_status "an unknown verb fails" 1 ptt nonesuch

DONBOX_PTT_PORT=1
assert_status "a client that is not there fails loudly" 1 ptt press
