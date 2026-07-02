import click
import subprocess
@click.command()
@click.option('--file', help='input file')
@click.option('--password', help='password')
@click.option('--output', help='output')
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