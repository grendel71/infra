import click
import subprocess
@click.command()
@click.option('--file', required=True, help='input .enc file')
@click.option('--password', required=True, help='decryption password')
@click.option('--output', required=True, help='output .json file')
def decrypt(file, password, output):
    subprocess.run(
        [
            "openssl", "enc", "-aes-256-cbc", "-d", "-pbkdf2",
            "-pass", f"pass:{password}",
            "-in", file,
            "-out", output,
        ],
        check=True,
    )


if __name__ == '__main__':
    decrypt()