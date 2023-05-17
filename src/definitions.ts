export interface ThinmooBlePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
