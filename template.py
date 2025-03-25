import os
import json
from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('templates'))

def render_and_save(template_name, output_dir, item):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)  
    template = env.get_template(template_name)
    rendered_content = template.render(item=item)
    output_path = os.path.join(output_dir, f"{item['tags']['common'][0]}.Dockerfile")
    with open(output_path, 'w') as f:
        f.write(rendered_content)
    print(f"Generated: {output_path}")
            
def main():  
    with open('arg.json', 'r') as f:
        args = json.load(f)
        
    if 'cann' in args:   
        for arg in args['cann']:
            if arg["os_name"] == "ubuntu":
                render_and_save('cann.ubuntu.Dockerfile.j2', 'cann', arg)
            else:
                render_and_save('cann.openeuler.Dockerfile.j2', 'cann', arg)
    else:
        print("No 'cann' field found in arg.json, skipping CANN Dockerfile generation.")

    if 'python' in args:
        for arg in args['python']:
            if arg["os_name"] == "ubuntu":
                render_and_save('python.ubuntu.Dockerfile.j2', 'python', arg)
            else:
                render_and_save('python.openeuler.Dockerfile.j2', 'python', arg)
    else:
        print("No 'python' field found in arg.json, skipping Python Dockerfile generation.")

    if 'pytorch' in args:
        for arg in args['pytorch']:
            render_and_save('pytorch.Dockerfile.j2', 'pytorch', arg)
    else:
        print("No 'pytorch' field found in arg.json, skipping PyTorch Dockerfile generation.")

    if 'mindspore' in args:
        for arg in args['mindspore']:
            render_and_save('mindspore.Dockerfile.j2', 'mindspore', arg)
    else:
        print("No 'mindspore' field found in arg.json, skipping MindSpore Dockerfile generation.")


if __name__ == "__main__":
    main()
